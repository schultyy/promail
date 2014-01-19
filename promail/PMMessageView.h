//
//  PMMessageView.h
//  promail
//
//  Created by DINH Viêt Hoà on 1/19/13.
//  Copyright (c) 2013 MailCore. All rights reserved.
//

#import  <Cocoa/Cocoa.h>
#include <MailCore/MailCore.h>
#import <WebKit/WebKit.h>

@protocol PMMessageViewDelegate;

@interface PMMessageView : NSView{
    WebView * _webView;
}

@property (nonatomic, copy) NSString * folder;
@property (nonatomic, strong) MCOAbstractMessage * message;

@property (nonatomic, assign) id <PMMessageViewDelegate> delegate;

@property (nonatomic, assign) BOOL prefetchIMAPImagesEnabled;
@property (nonatomic, assign) BOOL prefetchIMAPAttachmentsEnabled;

@end

@protocol PMMessageViewDelegate <NSObject>

@optional
- (NSData *) PMMessageView:(PMMessageView *)view dataForPartWithUniqueID:(NSString *)partUniqueID;
- (void) PMMessageView:(PMMessageView *)view fetchDataForPartWithUniqueID:(NSString *)partUniqueID
     downloadedFinished:(void (^)(NSError * error))downloadFinished;

- (NSString *) PMMessageView:(PMMessageView *)view templateForMainHeader:(MCOMessageHeader *)header;
- (NSString *) PMMessageView:(PMMessageView *)view templateForImage:(MCOAbstractPart *)part;
- (NSString *) PMMessageView:(PMMessageView *)view templateForAttachment:(MCOAbstractPart *)part;
- (NSString *) PMMessageView_templateForMessage:(PMMessageView *)view;
- (NSString *) PMMessageView:(PMMessageView *)view templateForEmbeddedMessage:(MCOAbstractMessagePart *)part;
- (NSString *) PMMessageView:(PMMessageView *)view templateForEmbeddedMessageHeader:(MCOMessageHeader *)header;
- (NSString *) PMMessageView_templateForAttachmentSeparator:(PMMessageView *)view;

- (NSDictionary *) PMMessageView:(PMMessageView *)view templateValuesForPartWithUniqueID:(NSString *)uniqueID;
- (NSDictionary *) PMMessageView:(PMMessageView *)view templateValuesForHeader:(MCOMessageHeader *)header;
- (BOOL) PMMessageView:(PMMessageView *)view canPreviewPart:(MCOAbstractPart *)part;
- (BOOL) PMMessageView:(PMMessageView *)msg shouldShowPart:(MCOAbstractPart *)part;

- (NSString *) PMMessageView:(PMMessageView *)view filteredHTMLForPart:(NSString *)html;
- (NSString *) PMMessageView:(PMMessageView *)view filteredHTMLForMessage:(NSString *)html;
- (NSData *) PMMessageView:(PMMessageView *)view previewForData:(NSData *)data isHTMLInlineImage:(BOOL)isHTMLInlineImage;

@end