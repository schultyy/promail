//
//  PMAccountSMTPViewController.m
//  promail
//
//  Created by Jan Schulte on 02/03/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMAccountSMTPViewController.h"

@interface PMAccountSMTPViewController ()

@end

@implementation PMAccountSMTPViewController

- (id)initWithWizardContext:(PMAccountWizardContext *)wizardContext
{
    self = [super initWithWizardContext:wizardContext];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(NSString *) title{
    return @"SMTP Settings";
}

@end
