//
//  PMAccountServerViewController.m
//  promail
//
//  Created by Jan Schulte on 28/02/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMAccountServerViewController.h"
#import "PMConnectionType.h"

@interface PMAccountServerViewController ()

@end

@implementation PMAccountServerViewController

- (id)initWithWizardContext:(PMAccountWizardContext *)wizardContext {
    self = [super initWithWizardContext:wizardContext andNibName:@"PMAccountServerView"];
    if (self) {
        id types = [[NSMutableArray alloc] init];
        
        [types addObject:[[PMConnectionType alloc] initWithName: @"STARTTLS" andKey: [NSNumber numberWithInt:0]]];
        [types addObject:[[PMConnectionType alloc] initWithName: @"TLS" andKey: [NSNumber numberWithInt:1]]];
        
        [self setConnectionTypes:types];
    }
    return self;
}

-(BOOL) canActivate{
    return [[self wizardContext] customConfigurationEnabled];
}

@end
