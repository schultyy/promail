//
//  PMMainController.h
//  promail
//
//  Created by Jan Schulte on 10/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PMFolderListController.h"
#import "PMMailDetailController.h"

@interface PMMainController : NSWindowController<NSToolbarDelegate>

-(id) initWithObjectContext: (NSManagedObjectContext *) context;

-(IBAction)refresh:(id)sender;

@property (retain) PMFolderListController *folderList;

@property (retain) PMMailDetailController *mailDetail;

@property IBOutlet NSBox *currentView;

@end
