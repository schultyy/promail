//
//  PMAccountServerViewController.m
//  promail
//
//  Created by Jan Schulte on 28/02/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMAccountIMAPViewController.h"

@interface PMAccountIMAPViewController ()

@end

@implementation PMAccountIMAPViewController

- (id)initWithWizardContext:(PMAccountWizardContext *)wizardContext {
    self = [super initWithWizardContext:wizardContext andNibName:@"PMAccountIMAPView"];
    if (self) {
    }
    return self;
}

-(NSString *) title{
    return @"Server settings";
}

-(NSNumber *) order{
    return [NSNumber numberWithInt:2];
}

@end
