//
//  PMAccountIMAPViewController.m
//  promail
//
//  Created by Jan Schulte on 02/03/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMAccountIMAPViewController.h"
#import "PMAccountWizardContext.h"

@interface PMAccountIMAPViewController ()

@end

@implementation PMAccountIMAPViewController

-(id) initWithWizardContext:(PMAccountWizardContext *) wizardContext{
    self = [super initWithWizardContext: wizardContext];
    if(self){
        firstTimeActivation = YES;
    }
    return self;
}

-(NSString *) title{
    return @"IMAP Settings";
}

-(void) activate{
    if(firstTimeActivation) {
        PMAccountWizardContext *context = [self wizardContext];
        [self setServer: context.imapServer];
        [self setPort: context.imapPort];

        if([context useEmailAddressAsUsername]){
            [self setUsername: context.emailAddress];
        }
        firstTimeActivation = NO;
        
        if([context imapEncryption] == EncryptionTypeTLS){
            self set
        }
    }
}

-(void) beforeNext{
    
}

@end
