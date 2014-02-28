//
//  PMAppDelegate.h
//  promail
//
//  Created by Jan Schulte on 10/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PMMainController.h"
#import "PMAccountWizardController.h"

@interface PMAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (retain) PMAccountWizardController *accountsController;
@property (retain) PMMainController *mainController;

- (IBAction)saveAction:(id)sender;

-(IBAction)preferences:(id)sender;

@end
