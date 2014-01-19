//
//  PMMailDetailController.m
//  promail
//
//  Created by DINH Viêt Hoà on 1/20/13.
//  Created by Jan Schulte on 24/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import "PMMailDetailController.h"
#import "PMSessionManager.h"
#import <MailCore/MailCore.h>

@interface PMMailDetailController ()

@end

@implementation PMMailDetailController

- (id)init
{
    self = [super initWithNibName:@"PMMailDetailView" bundle:nil];
    if (self) {
    }
    return self;
}

-(void) awakeFromNib{
    [self addObserver:self forKeyPath:@"currentMail" options:NSKeyValueObservingOptionNew context:nil];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString: NSStringFromSelector(@selector(currentMail))]){
        
    }
}


-(void) fetchBodyText{
    [self setIsBusy:YES];
    
    NSManagedObject *account = [[self currentMail] valueForKey:@"account"];
    NSNumber *uid = [[self currentMail] valueForKey:@"uid"];
    
    PMSessionManager *sessionManager = [[PMSessionManager alloc] initWithAccount:account];
    [sessionManager fetchBodyForMessage: uid completionBlock:^(NSError *error, NSData *data) {
        [self setIsBusy:NO];
    }];
}

- (MCOIMAPFetchContentOperation *) _fetchIMAPPartWithUniqueID:(NSString *)partUniqueID folder:(NSString *)folder
{
    NSLog(@"%@ is missing, fetching", partUniqueID);
    
    if ([_pending containsObject:partUniqueID]) {
        return nil;
    }
    
    MCOIMAPPart * part = (MCOIMAPPart *) [_message partForUniqueID:partUniqueID];
    NSAssert(part != nil, @"part != nil");
    
    [_pending addObject:partUniqueID];
    
    MCOIMAPFetchContentOperation * op = [_session fetchMessageAttachmentByUIDOperationWithFolder:folder uid:[_message uid] partID:[part partID] encoding:[part encoding]];
    [_ops addObject:op];
    [op start:^(NSError * error, NSData * data) {
        if ([error code] != MCOErrorNone) {
            [self _callbackForPartUniqueID:partUniqueID error:error];
            return;
        }
        
        NSAssert(data != NULL, @"data != nil");
        [_ops removeObject:op];
        [_storage setObject:data forKey:partUniqueID];
        [_pending removeObject:partUniqueID];
        NSLog(@"downloaded %@", partUniqueID);
        
        [self _callbackForPartUniqueID:partUniqueID error:nil];
    }];
    
    return op;
}

typedef void (^DownloadCallback)(NSError * error);

- (void) _callbackForPartUniqueID:(NSString *)partUniqueID error:(NSError *)error
{
    NSArray * blocks;
    blocks = [_callbacks objectForKey:partUniqueID];
    NSLog(@"%@", blocks);
    for(DownloadCallback block in blocks) {
        block(error);
    }
    NSLog(@"done: %@", blocks);
}

- (NSString *) PMMessageView:(PMMessageView *)view templateForAttachment:(MCOAbstractPart *)part
{
    return @"<div><img src=\"http://www.iconshock.com/img_jpg/OFFICE/general/jpg/128/attachment_icon.jpg\"/></div>\
    {{#HASSIZE}}\
    <div>- {{FILENAME}}, {{SIZE}}</div>\
    {{/HASSIZE}}\
    {{#NOSIZE}}\
    <div>- {{FILENAME}}</div>\
    {{/NOSIZE}}";
}

- (NSString *) PMMessageView_templateForMessage:(PMMessageView *)view
{
    return @"<div style=\"padding-bottom: 20px; font-family: Helvetica; font-size: 13px;\">{{HEADER}}</div><div>{{BODY}}</div>";
}

- (BOOL) PMMessageView:(PMMessageView *)view canPreviewPart:(MCOAbstractPart *)part
{
    // tiff, tif, pdf
    NSString * mimeType = [[part mimeType] lowercaseString];
    if ([mimeType isEqualToString:@"image/tiff"]) {
        return YES;
    }
    else if ([mimeType isEqualToString:@"image/tif"]) {
        return YES;
    }
    else if ([mimeType isEqualToString:@"application/pdf"]) {
        return YES;
    }
    
    NSString * ext = nil;
    if ([part filename] != nil) {
        if ([[part filename] pathExtension] != nil) {
            ext = [[[part filename] pathExtension] lowercaseString];
        }
    }
    if (ext != nil) {
        if ([ext isEqualToString:@"tiff"]) {
            return YES;
        }
        else if ([ext isEqualToString:@"tif"]) {
            return YES;
        }
        else if ([ext isEqualToString:@"pdf"]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSString *) PMMessageView:(PMMessageView *)view filteredHTML:(NSString *)html
{
    return html;
}

- (NSData *) PMMessageView:(PMMessageView *)view dataForPartWithUniqueID:(NSString *)partUniqueID
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FetchFullMessageEnabled"]) {
        MCOAttachment * attachment = (MCOAttachment *) [[_messageView message] partForUniqueID:partUniqueID];
        return [attachment data];
    }
    else {
        NSData * data = [_storage objectForKey:partUniqueID];
        return data;
    }
}

- (void) PMMessageView:(PMMessageView *)view fetchDataForPartWithUniqueID:(NSString *)partUniqueID
     downloadedFinished:(void (^)(NSError * error))downloadFinished
{
    MCOIMAPFetchContentOperation * op = [self _fetchIMAPPartWithUniqueID:partUniqueID folder:_folder];
    [op setProgress:^(unsigned int current, unsigned int maximum) {
        NSLog(@"progress content: %u/%u", current, maximum);
    }];
    if (op != nil) {
        [_ops addObject:op];
    }
    if (downloadFinished != NULL) {
        NSMutableArray * blocks;
        blocks = [_callbacks objectForKey:partUniqueID];
        if (blocks == nil) {
            blocks = [NSMutableArray array];
            [_callbacks setObject:blocks forKey:partUniqueID];
        }
        [blocks addObject: downloadFinished];
    }
}

- (NSData *) PMMessageView:(PMMessageView *)view previewForData:(NSData *)data isHTMLInlineImage:(BOOL)isHTMLInlineImage
{
    if (isHTMLInlineImage) {
        return data;
    }
    else {
        return [self _convertToJPEGData:data];
    }
}

#define IMAGE_PREVIEW_HEIGHT 300
#define IMAGE_PREVIEW_WIDTH 500

- (NSData *) _convertToJPEGData:(NSData *)data
{
    CGImageSourceRef imageSource;
    CGImageRef thumbnail;
    NSMutableDictionary * info;
    int width;
    int height;
    float quality;
    
    width = IMAGE_PREVIEW_WIDTH;
    height = IMAGE_PREVIEW_HEIGHT;
    quality = 1.0;
    
    imageSource = CGImageSourceCreateWithData((__bridge CFDataRef) data, NULL);
    if (imageSource == NULL)
        return nil;
    
    info = [[NSMutableDictionary alloc] init];
    [info setObject:(id) kCFBooleanTrue forKey:(id) kCGImageSourceCreateThumbnailWithTransform];
    [info setObject:(id) kCFBooleanTrue forKey:(id) kCGImageSourceCreateThumbnailFromImageAlways];
    [info setObject:(id) [NSNumber numberWithFloat:(float) IMAGE_PREVIEW_WIDTH] forKey:(id) kCGImageSourceThumbnailMaxPixelSize];
    thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef) info);
    
    CGImageDestinationRef destination;
    NSMutableData * destData = [NSMutableData data];
    
    destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef) destData,
                                                   (CFStringRef) @"public.jpeg",
                                                   1, NULL);
    
    CGImageDestinationAddImage(destination, thumbnail, NULL);
    CGImageDestinationFinalize(destination);
    
    CFRelease(destination);
    
    CFRelease(thumbnail);
    CFRelease(imageSource);
    
    return destData;
}


@end
