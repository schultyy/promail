//
// Created by Jan Schulte on 04/05/14.
// Copyright (c) 2014 schultyy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMFacade.h"


@interface PMMailFacade : PMFacade

-(NSManagedObject *) createNewMessage;

-(void) fetchMailsForAccount: (NSManagedObject *) account;

-(void) mark: (BOOL) seen mail: (NSManagedObject *) message finished: (void(^)()) finishedCallback;

-(void) sendMail: (NSManagedObject *) account
      recipients: (NSArray *) recipients
              cc: (NSArray *) cc
             bcc: (NSArray *) bcc
         subject: (NSString *) subject
            body: (NSString *) body;

@end
