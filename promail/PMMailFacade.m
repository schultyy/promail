//
// Created by Jan Schulte on 04/05/14.
// Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMMailFacade.h"
#import "Underscore.h"
#import <MailCore/MailCore.h>


@implementation PMMailFacade

#pragma mark Initializers

-(id) initWitManagedObjectContext: (NSManagedObjectContext *) context {
    self = [super init];
    if(self) {
        managedObjectContext = context;
    }
    return self;
}

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