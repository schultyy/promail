//
//  PMMessageView.m
//  promail
//
//  Created by DINH Viêt Hoà on 1/19/13.
//  Copyright (c) 2013 MailCore. All rights reserved.
//

#import "PMMessageView.h"
#include <MailCore/MailCore.h>
#import <WebKit/WebKit.h>
#import "PMCIDURLProtocol.h"
#import "PMMessageContentAdapter.h"

static NSString * mainJavascript = @"\
var imageElements = function() {\
var imageNodes = document.getElementsByTagName('img');\
return [].slice.call(imageNodes);\
};\
\
var findCIDImageURL = function() {\
var images = imageElements();\
\
var imgLinks = [];\
for (var i = 0; i < images.length; i++) {\
var url = images[i].getAttribute('src');\
if (url.indexOf('cid:') == 0 || url.indexOf('x-mailcore-image:') == 0)\
imgLinks.push(url);\
}\
return JSON.stringify(imgLinks);\
};\
\
var replaceImageSrc = function(info) {\
var images = imageElements();\
\
for (var i = 0; i < images.length; i++) {\
var url = images[i].getAttribute('src');\
if (url.indexOf(info.URLKey) == 0) {\
images[i].setAttribute('src', info.LocalPathKey);\
break;\
}\
}\
};\
";

static NSString * mainStyle = @"\
body {\
font-family: Helvetica;\
font-size: 14px;\
word-wrap: break-word;\
-webkit-text-size-adjust:none;\
-webkit-nbsp-mode: space;\
}\
\
pre {\
white-space: pre-wrap;\
}\
";

@interface PMMessageView () <MCOHTMLRendererIMAPDelegate>

@end

@implementation PMMessageView

+ (void) initialize
{
    [PMCIDURLProtocol registerProtocol];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    _webView = [[WebView alloc] initWithFrame:[self bounds]];
    [_webView setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
    [_webView setResourceLoadDelegate:self];
    [self addSubview:_webView];
    
    return self;
}

-(void) awakeFromNib{
    NSString *messageSelector = NSStringFromSelector(@selector(message));
    [self addObserver:self forKeyPath:messageSelector options: NSKeyValueObservingOptionNew context:NULL];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    NSString *messageSelector = NSStringFromSelector(@selector(message));
    if([keyPath isEqualToString: messageSelector]){
        [_webView stopLoading:nil];
        [self _refresh];
    }
}



- (void) _refresh
{
    NSString * content = [PMMessageContentAdapter convertMessage:_message withDelegate:self andFolder:_folder];

    [[_webView mainFrame] loadHTMLString:content baseURL:nil];
}

- (MCOAbstractPart *) _partForCIDURL:(NSURL *)url
{
    return [_message partForContentID:[url resourceSpecifier]];
}

- (MCOAbstractPart *) _partForUniqueID:(NSString *)partUniqueID
{
    return [_message partForUniqueID:partUniqueID];
}

- (NSData *) _dataForIMAPPart:(MCOIMAPPart *)part folder:(NSString *)folder
{
    NSData * data;
    NSString * partUniqueID = [part uniqueID];
    data = [[self delegate] PMMessageView:self dataForPartWithUniqueID:partUniqueID];
    if (data == NULL) {
        [[self delegate] PMMessageView:self fetchDataForPartWithUniqueID:partUniqueID downloadedFinished:^(NSError * error) {
            [self _refresh];
        }];
    }
    return data;
}

- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(id)dataSource
{
    MCOAbstractPart * part = NULL;
    
    if ([PMCIDURLProtocol isCID:[request URL]]) {
        part = [self _partForCIDURL:[request URL]];
    }
    else if ([PMCIDURLProtocol isXMailcoreImage:[ request URL]]) {
        NSString * specifier = [[request URL] resourceSpecifier];
        NSString * partUniqueID = specifier;
        part = [self _partForUniqueID:partUniqueID];
    }
    
    if (part != NULL) {
        if ([_message isKindOfClass:[MCOIMAPMessage class]]) {
            NSMutableURLRequest * mutableRequest = [request mutableCopy];
            NSString * partUniqueID = [part uniqueID];
            NSData * data = [[self delegate] PMMessageView:self dataForPartWithUniqueID:partUniqueID];
            if (data == NULL) {
                [[self delegate] PMMessageView:self fetchDataForPartWithUniqueID:partUniqueID downloadedFinished:^(NSError * error) {
                    NSData * downloadedData = [[self delegate] PMMessageView:self dataForPartWithUniqueID:partUniqueID];
                    NSData * previewData = [[self delegate] PMMessageView:self previewForData:downloadedData isHTMLInlineImage:[PMCIDURLProtocol isCID:[request URL]]];
                    [PMCIDURLProtocol partDownloadedMessage:_message partUniqueID:partUniqueID data:previewData];
                }];
            }
            [PMCIDURLProtocol startLoadingWithMessage:_message
                                          partUniqueID:partUniqueID
                                                  data:data
                                               request:mutableRequest];
            
            return mutableRequest;
        }
        else if ([_message isKindOfClass:[MCOMessageParser class]]) {
            NSMutableURLRequest * mutableRequest = [request mutableCopy];
            NSString * partUniqueID = [part uniqueID];
            NSData * data = [(MCOAttachment *) part data];
            NSData * previewData = [[self delegate] PMMessageView:self previewForData:data isHTMLInlineImage:[PMCIDURLProtocol isCID:[request URL]]];
            [PMCIDURLProtocol startLoadingWithMessage:_message
                                          partUniqueID:partUniqueID
                                                  data:previewData
                                               request:mutableRequest];
            
            return mutableRequest;
        }
        else {
            return request;
        }
    }
    else {
        return request;
    }
}

- (BOOL) MCOAbstractMessage:(MCOAbstractMessage *)msg canPreviewPart:(MCOAbstractPart *)part
{
    static NSMutableSet * supportedImageMimeTypes = NULL;
    if (supportedImageMimeTypes == NULL) {
        supportedImageMimeTypes = [[NSMutableSet alloc] init];
        [supportedImageMimeTypes addObject:@"image/png"];
        [supportedImageMimeTypes addObject:@"image/gif"];
        [supportedImageMimeTypes addObject:@"image/jpg"];
        [supportedImageMimeTypes addObject:@"image/jpeg"];
    }
    static NSMutableSet * supportedImageExtension = NULL;
    if (supportedImageExtension == NULL) {
        supportedImageExtension = [[NSMutableSet alloc] init];
        [supportedImageExtension addObject:@"png"];
        [supportedImageExtension addObject:@"gif"];
        [supportedImageExtension addObject:@"jpg"];
        [supportedImageExtension addObject:@"jpeg"];
    }
    
    if ([supportedImageMimeTypes containsObject:[[part mimeType] lowercaseString]])
        return YES;
    
    NSString * ext = nil;
    if ([part filename] != nil) {
        if ([[part filename] pathExtension] != nil) {
            ext = [[[part filename] pathExtension] lowercaseString];
        }
    }
    if (ext != nil) {
        if ([supportedImageExtension containsObject:ext])
            return YES;
    }
    
    if (![[self delegate] respondsToSelector:@selector(PMMessageView:canPreviewPart:)]) {
        return NO;
    }
    return [[self delegate] PMMessageView:self canPreviewPart:part];
}

- (BOOL) MCOAbstractMessage:(MCOAbstractMessage *)msg shouldShowPart:(MCOAbstractPart *)part
{
    if (![[self delegate] respondsToSelector:@selector(PMMessageView:shouldShowPart:)]) {
        return YES;
    }
    return [[self delegate] PMMessageView:self shouldShowPart:part];
}

- (NSDictionary *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateValuesForHeader:(MCOMessageHeader *)header
{
    if (![[self delegate] respondsToSelector:@selector(PMMessageView:templateValuesForHeader:)]) {
        return nil;
    }
    return [[self delegate] PMMessageView:self templateValuesForHeader:header];
}

- (NSDictionary *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateValuesForPart:(MCOAbstractPart *)part
{
    if (![[self delegate] respondsToSelector:@selector(PMMessageView:templateValuesForPartWithUniqueID:)]) {
        return nil;
    }
    return [[self delegate] PMMessageView:self templateValuesForPartWithUniqueID:[part uniqueID]];
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForMainHeader:(MCOMessageHeader *)header
{
    if (![[self delegate] respondsToSelector:@selector(PMMessageView:templateForMainHeader:)]) {
        return nil;
    }
    return [[self delegate] PMMessageView:self templateForMainHeader:header];
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForImage:(MCOAbstractPart *)part
{
    NSString * templateString;
    if ([[self delegate] respondsToSelector:@selector(PMMessageView:templateForImage:)]) {
        templateString = [[self delegate] PMMessageView:self templateForImage:part];
    }
    else {
        templateString = @"<img src=\"{{URL}}\"/>";
    }
    templateString = [NSString stringWithFormat:@"<div id=\"{{CONTENTID}}\">%@</div>", templateString];
    return templateString;
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForAttachment:(MCOAbstractPart *)part
{
    if (![[self delegate] respondsToSelector:@selector(PMMessageView:templateForAttachment:)]) {
        return NULL;
    }
    NSString * templateString = [[self delegate] PMMessageView:self templateForAttachment:part];
    templateString = [NSString stringWithFormat:@"<div id=\"{{CONTENTID}}\">%@</div>", templateString];
    return templateString;
}

- (NSString *) MCOAbstractMessage_templateForMessage:(MCOAbstractMessage *)msg
{
    if (![[self delegate] respondsToSelector:@selector(PMMessageView_templateForMessage:)]) {
        return NULL;
    }
    return [[self delegate] PMMessageView_templateForMessage:self];
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForEmbeddedMessage:(MCOAbstractMessagePart *)part
{
    if (![[self delegate] respondsToSelector:@selector(PMMessageView:templateForEmbeddedMessage:)]) {
        return NULL;
    }
    return [[self delegate] PMMessageView:self templateForEmbeddedMessage:part];
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForEmbeddedMessageHeader:(MCOMessageHeader *)header
{
    if (![[self delegate] respondsToSelector:@selector(PMMessageView:templateForEmbeddedMessageHeader:)]) {
        return NULL;
    }
    return [[self delegate] PMMessageView:self templateForEmbeddedMessageHeader:header];
}

- (NSString *) MCOAbstractMessage_templateForAttachmentSeparator:(MCOAbstractMessage *)msg
{
    if (![[self delegate] respondsToSelector:@selector(PMMessageView_templateForAttachmentSeparator:)]) {
        return NULL;
    }
    return [[self delegate] PMMessageView_templateForAttachmentSeparator:self];
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg filterHTMLForPart:(NSString *)html
{
    if (![[self delegate] respondsToSelector:@selector(PMMessageView:filteredHTMLForPart:)]) {
        return html;
    }
    return [[self delegate] PMMessageView:self filteredHTMLForPart:html];
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg filterHTMLForMessage:(NSString *)html
{
    if (![[self delegate] respondsToSelector:@selector(PMMessageView:filteredHTMLForMessage:)]) {
        return html;
    }
    return [[self delegate] PMMessageView:self filteredHTMLForMessage:html];
}

- (NSData *) MCOAbstractMessage:(MCOAbstractMessage *)msg dataForIMAPPart:(MCOIMAPPart *)part folder:(NSString *)folder
{
    return [self _dataForIMAPPart:part folder:folder];
}

- (void) MCOAbstractMessage:(MCOAbstractMessage *)msg prefetchAttachmentIMAPPart:(MCOIMAPPart *)part folder:(NSString *)folder
{
    if (!_prefetchIMAPAttachmentsEnabled)
        return;
    
    NSString * partUniqueID = [part uniqueID];
    [[self delegate] PMMessageView:self fetchDataForPartWithUniqueID:partUniqueID downloadedFinished:^(NSError * error) {
        // do nothing
    }];
}

- (void) MCOAbstractMessage:(MCOAbstractMessage *)msg prefetchImageIMAPPart:(MCOIMAPPart *)part folder:(NSString *)folder
{
    if (!_prefetchIMAPImagesEnabled)
        return;
    
    NSString * partUniqueID = [part uniqueID];
    [[self delegate] PMMessageView:self fetchDataForPartWithUniqueID:partUniqueID downloadedFinished:^(NSError * error) {
        // do nothing
    }];
}

@end