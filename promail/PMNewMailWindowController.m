//
//  PMNewMailSheet.m
//  promail
//
//  Created by Jan Schulte on 07/01/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMNewMailWindowController.h"

@interface PMNewMailWindowController()

@end

@implementation PMNewMailWindowController

-(id)initWithManagedObjectContext:(NSManagedObjectContext *)context {
    self = [super initWithWindowNibName:@"PMNewMailWindow"];
    if (self) {
        [self setManagedObjectContext:context];
    }
    return self;
}

-(void) windowDidLoad{
    [[self window] setBackgroundColor: [NSColor whiteColor]];
}

-(IBAction)discard:(id)sender{
    [self close];
}

@end
