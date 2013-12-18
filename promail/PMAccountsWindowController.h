//
//  PMAccountsWindowController.h
//  promail
//
//  Created by Jan Schulte on 18/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PMAccountsWindowController : NSWindowController<NSWindowDelegate>

@property (assign) NSManagedObjectContext *managedContext;

@property (retain) NSMutableIndexSet *selections;

@property (retain) NSString *password;

-(id) initWithManagedObjectContext: (NSManagedObjectContext *) context;

-(IBAction)setNewPassword:(id)sender;

@end
