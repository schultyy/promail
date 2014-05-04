//
//  PMNewMailSheet.h
//  promail
//
//  Created by Jan Schulte on 07/01/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PMAccountFacade.h"

@interface PMNewMailWindowController : NSWindowController

@property (retain) NSString *to;

@property (retain) NSString *subject;

@property (retain) NSString *body;

@property (retain) NSManagedObjectContext *managedObjectContext;

-(id) initWithManagedObjectContext: (NSManagedObjectContext *) context;

-(IBAction)discard:(id)sender;

@end
