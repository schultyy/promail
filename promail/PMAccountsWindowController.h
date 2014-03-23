//
//  PMAccountsWindowController.h
//  promail
//
//  Created by Jan Schulte on 18/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PMAccountsWindowController : NSWindowController<NSWindowDelegate>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (retain) NSMutableIndexSet *selections;

@property (retain) NSString *password;

@property (retain) NSArray *connectionTypes;

-(id) initWithManagedObjectContext: (NSManagedObjectContext *) context;

-(IBAction)addNewAccount:(id)sender;

-(IBAction)setNewPassword:(id)sender;

@end
