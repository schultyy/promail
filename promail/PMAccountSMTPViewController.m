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
        firstTimeActivation = YES;
    }
    return self;
}

-(NSString *) title{
    return @"SMTP Settings";
}

-(void) activate{
    if(firstTimeActivation) {
        PMAccountWizardContext *context = [self wizardContext];
        [self setServer: context.smtpServer];
        [self setPort: context.smtpPort];
        
        [self setUsername: context.emailAddress];
        [self setPassword: context.smtpPassword];
        
        if([context imapEncryption] == EncryptionTypeTLS){
            [self setSelections: [NSIndexSet indexSetWithIndex:1]];
        }
        else if([context imapEncryption] == EncryptionTypeSTARTTLS){
            [self setSelections: [NSIndexSet indexSetWithIndex:0]];
        }
        
        firstTimeActivation = NO;
    }
}

@end
