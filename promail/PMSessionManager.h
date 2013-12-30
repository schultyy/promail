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
    MCOIMAPSession *session;
}

-(id) initWithAccount: (NSManagedObject *) account;

-(void) fetchMessagesForFolder: (NSString *) folder completionBlock: (void (^)(NSError * error, NSArray * messages, MCOIndexSet * vanishedMessages))completionBlock;

-(void) fetchBodyForMessage: (NSNumber *) uid completionBlock: (void (^)(NSError *error, NSData *data)) completionBlock;

@end
