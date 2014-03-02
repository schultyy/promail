//
//  PMAccountVendorViewController.m
//  promail
//
//  Created by Jan Schulte on 02/03/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMAccountVendorViewController.h"

@interface PMAccountVendorViewController ()

@end

@implementation PMAccountVendorViewController

- (id)initWithWizardContext:(PMAccountWizardContext *)wizardContext
{
    self = [super initWithWizardContext:wizardContext andNibName:@"PMAccountVendorView"];
    if (self) {
        NSMutableArray *types = [NSMutableArray array];
        
        [types addObject:@"gmail"];
        [types addObject:@"yahoo"];
        [types addObject:@"outlook.com"];
        [types addObject:@"custom"];
        
        [self setVendors:types];
    }
    return self;
}

-(NSString *) title{
    return @"Select Account type";
}

@end
