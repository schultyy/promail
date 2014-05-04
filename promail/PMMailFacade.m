//
// Created by Jan Schulte on 04/05/14.
// Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMMailFacade.h"
#import "PMSessionManager.h"
#import "Underscore.h"
#import <MailCore/MailCore.h>


@implementation PMMailFacade

#pragma mark helpers

-(NSManagedObject *) createNewMessage{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext: managedObjectContext];
}

-(BOOL) containsMessage: (NSManagedObject *) account messageID: (NSString *) messageId{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity: [NSEntityDescription entityForName:@"Message" inManagedObjectContext: managedObjectContext ]];
    NSLog(@"Fetching for account %@", [account valueForKey:@"email"]);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"message_id == %@ AND account == %@", messageId, account];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *resultset = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(error){
        NSLog(@"%@", [error localizedDescription]);
    }
    BOOL result = [resultset count] > 0;
    return result;
}

#pragma mark public facade

-(void) fetchMailsForAccount: (NSManagedObject *) account {

    // If the account has no server: bail out
    if ([account valueForKey: @"imapServer"] == NULL ) {
        //[self notBusy];
        return;
    }

    PMSessionManager *sessionManager = [[PMSessionManager alloc] initWithAccount: account];

    [sessionManager fetchFlagsAndUIDsForFolder:@"INBOX" completionBlock:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages) {

        if(error){
            NSLog(@"***Error ocurred while fetching mails for account: %@", [account valueForKey:@"name"]);
            NSLog(@"%@", [error localizedDescription]);

            return;
        }

        NSArray *fetchedUids = Underscore.array(messages)
                .map(^(MCOIMAPMessage *obj){
            return [obj valueForKey:@"uid"];
        }).unwrap;

        NSArray *existingMessages = [account valueForKey:@"messages"];

        NSArray *existingUids = Underscore.array(existingMessages)
                .map(^(NSManagedObject *obj){
            return [obj valueForKey:@"uid"];
        }).unwrap;

        NSArray *uidsToBeDeleted = Underscore.without(existingUids, fetchedUids);

        //get me (solo and the wookie)*
        //* all messages which need to be deleted
        NSArray *messagesToBeDeleted = Underscore.filter(existingMessages, ^BOOL (NSManagedObject *obj){
            NSNumber *uid = [obj valueForKey:@"uid"];
            return Underscore.any(uidsToBeDeleted, ^BOOL (NSNumber *number){
                return [number isEqualToNumber:uid];
            });
        });

        Underscore.arrayEach(messagesToBeDeleted, ^(id msg){
            [managedObjectContext deleteObject: msg];
        });

        //Update flags
        Underscore.arrayEach(messages, ^(MCOIMAPMessage *msg){
            BOOL seen = ([msg flags] & MCOMessageFlagSeen) == MCOMessageFlagSeen;
            NSManagedObject *found = Underscore.find([account valueForKey:@"messages"], ^BOOL (NSManagedObject *obj){
                return [[obj valueForKey:@"uid"] isEqualToNumber: [msg valueForKey:@"uid"]];
            });
            [found setValue:[NSNumber numberWithBool:seen] forKey:@"seen"];
        });

        [sessionManager fetchMessagesForFolder:@"INBOX" lastUID: [sessionManager lastUID] completionBlock:^(NSError * error, NSArray * fetchedMessages, MCOIndexSet * vanishedMessages) {
            if(error) {
                NSLog(@"Error downloading message headers:%@", [error localizedDescription]);

            }
            [self processMessages: fetchedMessages forAccount: account];
        }];
    }];
}

-(void)processMessages: (NSArray *) newMails forAccount: (NSManagedObject *) account {
    Underscore.arrayEach(newMails, ^(MCOIMAPMessage *obj){
        NSString *messageId = [[obj header] messageID];
        NSNumber *gmailMessageId = [NSNumber numberWithUnsignedLongLong: obj.gmailMessageID];
        NSNumber *gmailThreadId  = [NSNumber numberWithUnsignedLongLong: obj.gmailThreadID];

        if([self containsMessage:account messageID: messageId]){
            return;
        }

        id msg = [self createNewMessage];
        [msg setValue:account forKey:@"account"];

        NSString *subject = obj.header.subject;
        NSString *from = obj.header.from.mailbox;
        NSNumber *uid = [NSNumber numberWithInt:obj.uid];
        BOOL seen = ([obj flags] & MCOMessageFlagSeen) == MCOMessageFlagSeen;

        NSArray *toList = Underscore.array([[obj header] to])
                .map(^id (MCOAddress *address){
            return [address nonEncodedRFC822String];
        }).unwrap;

        NSString *to   = [toList componentsJoinedByString:@","];
        NSString *cc   = [obj.header.cc componentsJoinedByString:@","];
        NSString *bcc  = [obj.header.bcc componentsJoinedByString:@","];

        [msg setValue: subject forKey: @"subject"];
        [msg setValue: from forKey:@"from"];
        [msg setValue: to forKey: @"to"];
        [msg setValue: cc forKey:@"cc"];
        [msg setValue: bcc forKey:@"bcc"];
        [msg setValue: messageId forKey: @"message_id"];
        [msg setValue: [[obj header] date] forKey: @"date"];
        [msg setValue: uid forKey:@"uid"];
        [msg setValue: gmailThreadId forKey:@"gmail_thread_id"];
        [msg setValue: gmailMessageId forKey:@"gmail_message_id"];

        if (gmailThreadId != nil) {
            [msg setValue: [self threadForMailWithSubject:subject andGmailThreadId:gmailThreadId] forKey: @"thread"];
        } else {
            [msg setValue: [self threadForMailWithSubject:subject] forKey: @"thread"];
        }

        [msg setValue: [NSNumber numberWithBool:seen] forKey:@"seen"];
        [msg setValue: [NSNumber numberWithLong: obj.attachments.count] forKey:@"attachment_count"];

        if (obj.gmailLabels) {
            Underscore.arrayEach(obj.gmailLabels, ^(NSString *label){
                id gmailLabel = [self gmailLabelForText:label];
                NSMutableSet *messages = [gmailLabel mutableSetValueForKey:@"messages"];
                [messages addObject:msg];
            });
        }
    });
    NSError *errors = nil;
    [managedObjectContext save:&errors];

    //TODO: Better error handling here
    if(errors){
        NSLog(@"Errors: %@", [errors localizedDescription]);
    }
}

-(void) mark: (BOOL) seen mail: (NSManagedObject *) message finished: (void(^)()) finishedCallback {

    NSNumber *uid = [message valueForKey:@"uid"];
    NSManagedObject *account = [message valueForKey:@"account"];
    PMSessionManager *sessionManager = [[PMSessionManager alloc] initWithAccount: account];

    [sessionManager markSeen:uid Seen:seen completionBlock:^(NSError *error) {
        if(error){
            NSLog(@"Error: %@", [error localizedDescription]);
        }else{
            [message setValue: [NSNumber numberWithBool: seen] forKey:@"seen"];
        }
        if(finishedCallback){
            finishedCallback();
        }
    }];
}

#pragma mark GmailThread

-(id) threadForMailWithSubject: (NSString*)subject {
    // Todo: implement a thread finder for stuff that doesn't have a gmail thread ID
    return nil;
}

-(id) threadForMailWithSubject: (NSString*)subject andGmailThreadId:(NSNumber*) gmailThreadId {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity: [NSEntityDescription entityForName:@"Thread" inManagedObjectContext: managedObjectContext ]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gmail_thread_id == %@", gmailThreadId];
    [fetchRequest setPredicate:predicate];

    NSError *error = nil;
    NSArray *resultset = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!error && [resultset count] > 0){
        return [resultset firstObject];
    }

    id thread = [NSEntityDescription insertNewObjectForEntityForName:@"Thread" inManagedObjectContext: managedObjectContext];
    [thread setValue: gmailThreadId forKey:@"gmail_thread_id"];
    [thread setValue: subject forKey:@"subject"];

    return thread;
}

-(id) gmailLabelForText: (NSString*) label {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity: [NSEntityDescription entityForName:@"GmailLabel" inManagedObjectContext: managedObjectContext ]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", label];
    [fetchRequest setPredicate:predicate];

    NSError *error = nil;
    NSArray *resultSet = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!error && [resultSet count] > 0){
        return [resultSet firstObject];
    }

    id gmailLabel = [NSEntityDescription insertNewObjectForEntityForName:@"GmailLabel" inManagedObjectContext: managedObjectContext];
    [gmailLabel setValue: label forKey:@"name"];

    return gmailLabel;
}



@end
