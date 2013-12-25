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

-(id) initWithObjectContext: (NSManagedObjectContext *) context;

-(void)loadMails;

@end