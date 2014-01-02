//
//  PMFolderListController.m
//  promail
//
//  Created by Jan Schulte on 24/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import "PMFolderListController.h"
#import "PMSessionManager.h"
#import <MailCore/MailCore.h>
#import "PMConstants.h"
#import "Underscore.h"
#import "SSKeychain.h"

@interface PMFolderListController ()

@end

@implementation PMFolderListController

- (id)initWithObjectContext:(NSManagedObjectContext *)context
{
    self = [super initWithNibName:@"PMFolderListView" bundle:nil];
    if (self) {
        [self setStatusText:@""];
        [self setManagedObjectContext: context];
        [self setSortDescriptors: [NSArray arrayWithObject:
                                   [NSSortDescriptor sortDescriptorWithKey:@"date" ascending: NO]]];
        [self setBusyIndicatorVisible:NO];
    }
    return self;
}

-(void)awakeFromNib{
    [[self tableView] setDoubleAction:@selector(tableViewDoubleClick:)];
    [[self tableView] setTarget:self];
}

-(void) tableViewDoubleClick: (id) sender{
    NSManagedObject *message = [[[self mailArrayController] arrangedObjects] objectAtIndex: [sender selectedRow]];

    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:@"message"];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc postNotificationName:PMShowMessageDetail object:nil userInfo:userInfo];
}

-(void) processNewMails: (NSArray *) newMails forAccount: (NSManagedObject *) account{
    Underscore.arrayEach(newMails, ^(MCOIMAPMessage *obj){
        NSString *messageId = [[obj header] messageID];
        
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
        [msg setValue:from forKey:@"from"];
        [msg setValue:to forKey: @"to"];
        [msg setValue:cc forKey:@"cc"];
        [msg setValue:bcc forKey:@"bcc"];
        [msg setValue: messageId forKey: @"message_id"];
        [msg setValue: [[obj header] date] forKey: @"date"];
        [msg setValue: uid forKey:@"uid"];
        [msg setValue: [NSNumber numberWithBool:seen] forKey:@"seen"];
    });
    NSError *errors = nil;
    [[self managedObjectContext] save:&errors];
    if(errors){
        [self setStatusText: [errors localizedDescription]];
        NSLog(@"Errors: %@", [errors localizedDescription]);
        return;
    }
    [self clearStatus];
}

-(void) clearStatus{
    [self setStatusText:@""];
    [self setBusyIndicatorVisible:NO];
}

-(NSManagedObject *) createNewMessage{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext: self.managedObjectContext];
}

-(BOOL) containsMessage: (NSManagedObject *) account messageID: (NSString *) messageId{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity: [NSEntityDescription entityForName:@"Message" inManagedObjectContext: self.managedObjectContext ]];
    NSLog(@"Fetching for account %@", [account valueForKey:@"email"]);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"message_id == %@ AND account == %@", messageId, account];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *resultset = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if(error){
        [self setStatusText: [error localizedDescription]];
    }
    BOOL result = [resultset count] > 0;
    return result;
}


-(void) fetchMailsForAccount: (NSManagedObject *) account{
    id str = [NSString stringWithFormat:@"Fetching mails for account %@", [account valueForKey: @"name"]];
    [self setStatusText:str];
    
    PMSessionManager *sessionManager = [[PMSessionManager alloc] initWithAccount: account];

    [sessionManager fetchFlagsAndUIDsForFolder:@"INBOX" completionBlock:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages) {
        
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
            [self.managedObjectContext deleteObject: msg];
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
                NSLog(@"Error downloading message headers:%@", error);
                [self setStatusText:[error localizedDescription]];
            }
            [self processNewMails:fetchedMessages forAccount: account];
        }];
    }];
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
    NSLog(@"Accounts: %lu", (unsigned long)[results count]);
    return results;
}

-(void)loadMails{
    [self setBusyIndicatorVisible:YES];
    
    Underscore.arrayEach([self accounts], ^(id obj){
        [self fetchMailsForAccount: obj];
    });
}

-(IBAction)markAsRead:(id)sender{
    NSLog(@"mark as read");
}

@end
