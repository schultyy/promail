//
//  PMFolderListController.h
//  promail
//
//  Created by Jan Schulte on 24/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PMMailFacade.h"

@interface PMFolderListController : NSViewController

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (retain) NSArray *sortDescriptors;

@property (retain) PMMailFacade *mailFacade;

@property IBOutlet NSTableView *tableView;

@property IBOutlet NSArrayController *mailArrayController;

-(id) initWithObjectContext: (NSManagedObjectContext *) context;

-(NSArray *) accounts;

-(void) tableViewDoubleClick: (id) sender;

-(void)loadMails;

-(IBAction)markAsRead:(id)sender;

-(IBAction)markAsUnread:(id)sender;

@end
