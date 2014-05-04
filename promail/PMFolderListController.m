//
//  PMFolderListController.m
//  promail
//
//  Created by Jan Schulte on 24/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import "Underscore.h"
#import "PMFolderListController.h"
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
    
    Underscore.arrayEach([self accounts], ^(id account){
        id str = [NSString stringWithFormat:@"Fetching mails for account %@", [account valueForKey: @"name"]];
        [self busy:str];
        [[self mailFacade] fetchMailsForAccount: account];
    });
}

-(IBAction)markAsRead:(id)sender{
    [self mark:YES];
}

-(IBAction)markAsUnread:(id)sender{
    [self mark:NO];
}

-(void) mark: (BOOL) seen {
    NSInteger selectedRow = [self.tableView selectedRow];
    NSManagedObject *thisMessage = [[[self mailArrayController] arrangedObjects] objectAtIndex: ((NSUInteger)selectedRow)];
    [self busy:@"Marking message"];
    [[self mailFacade] mark: seen mail: thisMessage finished:^ {
        [self notBusy];
    }];
}

@end
