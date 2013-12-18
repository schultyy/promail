//
//  PMAccountsWindowController.m
//  promail
//
//  Created by Jan Schulte on 18/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import "PMAccountsWindowController.h"

@interface PMAccountsWindowController ()

@end

@implementation PMAccountsWindowController

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super initWithWindowNibName:@"AccountsWindow"];
    if (self) {
        [self setManagedContext:context];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end