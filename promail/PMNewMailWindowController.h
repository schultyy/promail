//
//  PMNewMailSheet.h
//  promail
//
//  Created by Jan Schulte on 07/01/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PMNewMailWindowController : NSWindowController

@property (retain) NSString *to;

@property (retain) NSString *subject;

@property (retain) NSString *body;

-(IBAction)discard:(id)sender;

@end
