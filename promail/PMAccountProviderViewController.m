//
//  PMAccountProviderViewController.m
//  promail
//
//  Created by Jan Schulte on 02/03/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMAccountProviderViewController.h"
#import "PMAccountProvider.h"
#import "PMAccountDefault.h"
#import "PMAccountDefaultsManager.h"
#import "PMConstants.h"

@interface PMAccountProviderViewController ()

@end

@implementation PMAccountProviderViewController

- (id)initWithWizardContext:(PMAccountWizardContext *)wizardContext
{
    self = [super initWithWizardContext:wizardContext andNibName:@"PMAccountProviderView"];
    if (self) {
        [self setProviders:[NSArray arrayWithObjects:
         [[PMAccountProvider alloc] initWithKey: PMAccountDefaultGmail andDisplayName: @"Google Mail"],
         [[PMAccountProvider alloc] initWithKey: PMAccountDefaultYahoo andDisplayName: @"Yahoo"],
         [[PMAccountProvider alloc] initWithKey: PMAccountDefaultOutlook andDisplayName: @"Outlook"],
         [[PMAccountProvider alloc] initWithKey: PMAccountDefaultCustom andDisplayName: @"Custom"], nil]];
        
    }
    return self;
}

-(NSString *) title{
    return @"Select Account type";
}

-(void) beforeNext{
    PMAccountProvider *selectedProvider = [[self providers] objectAtIndex: self.selections.firstIndex];
    PMAccountDefault *accountDefault = [PMAccountDefaultsManager SettingsForKey:[selectedProvider providerKey]];
    [[self wizardContext] copyFromDefaults: accountDefault];
}

@end
