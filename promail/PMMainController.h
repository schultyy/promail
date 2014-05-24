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
#import "PMNewMailWindowController.h"
#import "PMAccountFacade.h"

@interface PMMainController : NSWindowController<NSToolbarDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (retain) PMFolderListController *folderList;

@property (retain) PMMailDetailController *mailDetail;

@property (retain) PMNewMailWindowController *composeMailEditor;

@property (retain) PMAccountFacade *accountFacade;

@property (retain) NSString *statusText;

@property (assign) BOOL busyIndicatorVisible;

@property IBOutlet NSBox *detailView;

@property IBOutlet NSBox *listView;

-(id) initWithObjectContext: (NSManagedObjectContext *) context;

-(void) refresh;

-(void) writeNew;

@end
