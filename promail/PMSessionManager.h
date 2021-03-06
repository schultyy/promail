//
//  PMSessionManager.h
//  promail
//
//  Created by Jan Schulte on 30/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>

@interface PMSessionManager : NSObject{
    NSManagedObject *account;
    MCOIMAPSession *imapSession;
    MCOSMTPSession *smtpSession;
}

-(id) initWithAccount: (NSManagedObject *) account;

-(void) fetchMessagesForFolder: (NSString *) folder lastUID: (NSNumber *) lastUID completionBlock: (void (^)(NSError * error, NSArray * messages, MCOIndexSet * vanishedMessages))completionBlock;

-(void) fetchFlagsAndUIDsForFolder: (NSString *) folder completionBlock: (void (^)(NSError * error, NSArray * messages, MCOIndexSet * vanishedMessages))completionBlock;

-(void) fetchBodyForMessage: (NSNumber *) uid completionBlock: (void (^)(NSError *error, NSData *data)) completionBlock;

-(void) markSeen:(NSNumber *)uid Seen: (BOOL) isSeen completionBlock: (void (^)(NSError *error)) completionBlock;

-(NSString *) htmlBodyFromMessage: (NSData *)message;

-(NSNumber *) lastUID;

-(void) sendMail: (NSArray *) recipients
              cc: (NSArray *) cc
             bcc: (NSArray *) bcc
         subject: (NSString *) subject
            body: (NSString *) body;
@end
