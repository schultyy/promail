//
//  PMAccountProviderViewController.m
//  promail
//
//  Created by Jan Schulte on 02/03/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMAccountProviderViewController.h"
#import "PMConstants.h"

@interface PMAccountProviderViewController ()

@end

@implementation PMAccountProviderViewController

- (id)initWithWizardContext:(PMAccountWizardContext *)wizardContext
{
    self = [super initWithWizardContext:wizardContext andNibName:@"PMAccountProviderView"];
    if (self) {
        NSDictionary *providers = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"Google Mail", PMAccountDefaultGmail,
                                   @"Yahoo", PMAccountDefaultYahoo,
                                   @"Outlook.com", PMAccountDefaultOutlook,
                                   @"Custom", PMAccountDefaultCustom, nil];
        
        [self setProviders: providers];
    }
    return self;
}

-(NSString *) title{
    return @"Select Account type";
}

@end
