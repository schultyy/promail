//
//  PMNewMailSheet.h
//  promail
//
//  Created by Jan Schulte on 07/01/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PMMailFacade.h"

@interface PMNewMailWindowController : NSWindowController

@property (retain) NSString *to;

@property (retain) NSString *subject;

@property (retain) NSString *body;

@property (retain) NSManagedObjectContext *managedObjectContext;

@property (retain) PMMailFacade *mailFacade;

@property (assign) NSManagedObject *selectedAccount;

-(id) initWithManagedObjectContext: (NSManagedObjectContext *) context;

-(IBAction) sendMail: (id) sender;

-(IBAction)discard:(id)sender;

@end
