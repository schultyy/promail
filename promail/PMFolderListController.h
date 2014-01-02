//
//  PMFolderListController.h
//  promail
//
//  Created by Jan Schulte on 24/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PMFolderListController : NSViewController

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (retain) NSString *statusText;

@property (retain) NSArray *sortDescriptors;

@property (assign) BOOL busyIndicatorVisible;

@property IBOutlet NSTableView *tableView;

@property IBOutlet NSArrayController *mailArrayController;

-(id) initWithObjectContext: (NSManagedObjectContext *) context;

-(void) tableViewDoubleClick: (id) sender;

-(void)loadMails;

-(IBAction)markAsRead:(id)sender;

-(IBAction)markAsUnread:(id)sender;

@end
