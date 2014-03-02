//
//  PMAccountServerViewController.m
//  promail
//
//  Created by Jan Schulte on 28/02/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMAccountServerViewController.h"

@interface PMAccountServerViewController ()

@end

@implementation PMAccountServerViewController

- (id)initWithWizardContext:(PMAccountWizardContext *)wizardContext {
    self = [super initWithWizardContext:wizardContext andNibName:@"PMAccountServerView"];
    if (self) {
    }
    return self;
}

-(NSString *) title{
    return @"Server settings";
}


@end
