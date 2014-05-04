//
//  PMFolderListController.m
//  promail
//
//  Created by Jan Schulte on 24/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//
#import <MailCore/MailCore.h>
#import "Underscore.h"
#import "SSKeychain.h"
#import "PMFolderListController.h"
#import "PMSessionManager.h"
#import "PMMailFacade.h"
#import "PMConstants.h"

@interface PMFolderListController ()

@end

@implementation PMFolderListController

- (id)initWithObjectContext:(NSManagedObjectContext *)context
{
    self = [super initWithNibName:@"PMFolderListView" bundle:nil];
    if (self) {
        [self setManagedObjectContext: context];
        [self setSortDescriptors: [NSArray arrayWithObject:
                                   [NSSortDescriptor sortDescriptorWithKey:@"date" ascending: NO]]];
        [self setMailFacade: [[PMMailFacade alloc] initWitManagedObjectContext: context]];
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

    [[self mailFacade] processMessages:newMails forAccount: account];
    [self notBusy];
}

-(void) busy: (NSString *) busyText{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: busyText, YES, nil] forKeys: [NSArray arrayWithObjects: @"busyText", @"busy", nil]];
    
    [nc postNotificationName:PMStatusFetchMailBusy object:nil userInfo:userInfo];
}

-(void) notBusy{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:NO, @"busy", nil];
    
    [nc postNotificationName:PMStatusFetchMailNotBusy object: userInfo];
}





-(void) fetchMailsForAccount: (NSManagedObject *) account{
    id str = [NSString stringWithFormat:@"Fetching mails for account %@", [account valueForKey: @"name"]];
    
    // If the account has no server: bail out
    if ([account valueForKey: @"imapServer"] == NULL ) {
        [self notBusy];
        return;
    }
    
    [self busy:str];
    
    PMSessionManager *sessionManager = [[PMSessionManager alloc] initWithAccount: account];

    [sessionManager fetchFlagsAndUIDsForFolder:@"INBOX" completionBlock:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages) {
        
        if(error){
            NSLog(@"***Error ocurred while fetching mails for account: %@", [account valueForKey:@"name"]);
            NSLog(@"%@", [error localizedDescription]);
            [self notBusy];
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
                NSLog(@"Error downloading message headers:%@", [error localizedDescription]);

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
    return results;
}

-(void)loadMails{
    [self busy:@""];
    
    Underscore.arrayEach([self accounts], ^(id obj){
        [self fetchMailsForAccount: obj];
    });
}

-(IBAction)markAsRead:(id)sender{
    [self mark:YES];
}

-(IBAction)markAsUnread:(id)sender{
    [self mark:NO];
}

-(void) mark: (BOOL) seen {
    NSUInteger selectedRow = [self.tableView selectedRow];
    
    NSManagedObject *message = [[[self mailArrayController] arrangedObjects] objectAtIndex: selectedRow];
    NSNumber *uid = [message valueForKey:@"uid"];
    NSManagedObject *account = [message valueForKey:@"account"];
    PMSessionManager *sessionManager = [[PMSessionManager alloc] initWithAccount: account];
    
    [self busy:@""];
    
    [sessionManager markSeen:uid Seen:seen completionBlock:^(NSError *error) {
        if(error){
            NSLog(@"Error: %@", [error localizedDescription]);
        }else{
            [message setValue: [NSNumber numberWithBool: seen] forKey:@"seen"];
        }
        [self notBusy];
    }];
}

@end
