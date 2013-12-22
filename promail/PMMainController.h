//
//  PMMainController.h
//  promail
//
//  Created by Jan Schulte on 10/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PMMainController : NSWindowController

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (retain) NSString *statusText;

@property (retain) NSArray *sortDescriptors;

-(id) initWithObjectContext: (NSManagedObjectContext *) context;

-(IBAction)loadMails:(id)sender;

@end
