//
//  PMMainController.m
//  promail
//
//  Created by Jan Schulte on 10/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import "PMMainController.h"
#import <MailCore/MailCore.h>
#import "PMConstants.h"
#import "Underscore.h"
#import "SSKeychain.h"

@interface PMMainController ()

@end

@implementation PMMainController

- (id)initWithObjectContext:(NSManagedObjectContext *)context
{
    self = [super initWithWindowNibName:@"MainWindow"];
    if(self){
        [self setManagedObjectContext: context];
        [self setSortDescriptors: [NSArray arrayWithObject:
                                    [NSSortDescriptor sortDescriptorWithKey:@"date" ascending: NO]]];
    }
    return self;
}

-(void) awakeFromNib{
    [[self window] setBackgroundColor: NSColor.whiteColor];
}

-(NSArray *) accounts{
    NSFetchRequest *fetchAccounts = [[NSFetchRequest alloc] init];
    [fetchAccounts setEntity: [NSEntityDescription entityForName:@"Account" inManagedObjectContext: self.managedObjectContext]];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchAccounts error:&error];
    if (error) {
        NSLog(@"Error: %@\n%@", [error localizedDescription], [error userInfo]);
        return nil;
    }
    return results;
}

-(IBAction)loadMails:(id)sender{
    Underscore.arrayEach([self accounts], ^(id obj){
        [self fetchMailsForAccount: obj];
    });
}

-(NSString *) fetchPassword: (NSString *) email{
    return [SSKeychain passwordForService:PMApplicationName account:email];
}

-(void) fetchMailsForAccount: (NSManagedObject *) account{
    MCOIMAPSession *session = [[MCOIMAPSession alloc] init];
    session.hostname = [account valueForKey:@"server"];

    NSInteger num = [[account valueForKey:@"port"] integerValue];
    session.port = num;
    session.username = [account valueForKey:@"email"];
    session.password = [self fetchPassword: [account valueForKey: @"email"]];
    BOOL useSSL = [[account valueForKey:@"use_ssl"] boolValue];
    if(useSSL){
       session.connectionType = MCOConnectionTypeTLS;
    }
    else{
        session.connectionType = MCOConnectionTypeClear;
    }
    
    MCOIndexSet *uidSet = [MCOIndexSet indexSetWithRange:MCORangeMake(1,UINT64_MAX)];
    MCOIMAPFetchMessagesOperation *fetchOperation =
    [session fetchMessagesByUIDOperationWithFolder:@"INBOX"
                                       requestKind:MCOIMAPMessagesRequestKindHeaders
                                              uids:uidSet];
    
    [fetchOperation start:^(NSError * error, NSArray * fetchedMessages, MCOIndexSet * vanishedMessages) {
        if(error) {
            NSLog(@"Error downloading message headers:%@", error);
        }
        [self processNewMails:fetchedMessages forAccount: account];
    }];
}

-(NSManagedObject *) createNewMessage{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext: self.managedObjectContext];
}

-(BOOL) containsMessage: (NSString *) messageId{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity: [NSEntityDescription entityForName:@"Message" inManagedObjectContext: self.managedObjectContext ]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"message_id == %@", messageId];
    [fetchRequest setPredicate:predicate];
    NSArray *resultset = [[self managedObjectContext] executeFetchRequest:fetchRequest error:nil];
    BOOL result = [resultset count] > 0;
    return result;
}

-(void) processNewMails: (NSArray *) newMails forAccount: (NSManagedObject *) account{
    Underscore.arrayEach(newMails, ^(MCOIMAPMessage *obj){
        NSString *messageId = [[obj header] messageID];
        
        if([self containsMessage:messageId]){
            return;
        }
        
        id msg = [self createNewMessage];
        [msg setValue:account forKey:@"account"];
        
        NSString *subject = obj.header.subject;
        NSString *from = obj.header.from.mailbox;
        
        NSArray *toList = Underscore.array([[obj header] to])
            .map(^id (MCOAddress *address){
                return [address nonEncodedRFC822String];
        }).unwrap;
        
        NSString *to   = [toList componentsJoinedByString:@","];
        NSString *cc   = [obj.header.cc componentsJoinedByString:@","];
        NSString *bcc  = [obj.header.bcc componentsJoinedByString:@","];

        [msg setValue: subject forKey: @"subject"];
        [msg setValue:from forKey:@"from"];
        [msg setValue:to forKey: @"to"];
        [msg setValue:cc forKey:@"cc"];
        [msg setValue:bcc forKey:@"bcc"];
        [msg setValue: messageId forKey: @"message_id"];
        [msg setValue: [[obj header] date] forKey: @"date"];
    });
    NSError *errors = nil;
    [[self managedObjectContext] save:&errors];
    if(!errors){
        return;
    }
    NSLog(@"Errors: %@", [errors localizedDescription]);
}

@end
