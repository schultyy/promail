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

-(id) init
{
    self = [super initWithWindowNibName:@"PMNewMailSheet"];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void) windowDidLoad{
    [[self window] setBackgroundColor: [NSColor whiteColor]];
}

-(IBAction)discard:(id)sender{
    [NSApp endSheet: [self window]];
}

@end
