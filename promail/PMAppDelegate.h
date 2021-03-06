//
//  PMAppDelegate.h
//  promail
//
//  Created by Jan Schulte on 10/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PMMainController.h"
#import "PMAccountsWindowController.h"
#import "PMAccountWizardController.h"

@interface PMAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (retain) PMAccountWizardController *accountsWizardController;
@property (retain) PMAccountsWindowController *accountsController;
@property (retain) PMMainController *mainController;

- (IBAction)saveAction:(id)sender;

-(IBAction)preferences:(id)sender;

-(IBAction)addAccount:(id)sender;

-(IBAction)writeNewMail:(id)sender;

-(IBAction)refreshAccounts:(id)sender;

@end
