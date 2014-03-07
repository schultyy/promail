//
//  PMAccountFinishViewController.m
//  promail
//
//  Created by Jan Schulte on 07/03/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMAccountFinishViewController.h"

@interface PMAccountFinishViewController ()

@end

@implementation PMAccountFinishViewController

- (id)initWithWizardContext:(PMAccountWizardContext *)wizardContext
{
    self = [super initWithWizardContext:wizardContext andNibName:@"PMAccountFinishView"];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(NSString *) title{
    NSString *accountName = [[self wizardContext] fullName];
    return [NSString stringWithFormat:@"Created new account %@",accountName];
}

@end
