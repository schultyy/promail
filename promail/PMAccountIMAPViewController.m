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

        [self setUsername: context.emailAddress];
        [self setPassword: context.imapPassword];
        
        if([context imapEncryption] == EncryptionTypeTLS){
            [self setSelections: [NSIndexSet indexSetWithIndex:1]];
        }
        else if([context imapEncryption] == EncryptionTypeSTARTTLS){
            [self setSelections: [NSIndexSet indexSetWithIndex:0]];
        }
        
        firstTimeActivation = NO;
    }
}

-(void) beforeNext{
    [[self wizardContext] setImapEncryption: self.encryptionType];
    [[self wizardContext] setImapPassword:self.password];
    [[self wizardContext] setImapPort:self.port];
    [[self wizardContext] setImapServer:self.server];
    [[self wizardContext] setImapUsername:self.username];
    
    if([[self wizardContext] customConfigurationEnabled]){
        if([[[self wizardContext] smtpServer] length] == 0) {
            [[self wizardContext] setSmtpServer: self.wizardContext.imapServer];
        }
        if([[[self wizardContext] smtpUsername] length] == 0) {
            [[self wizardContext] setSmtpUsername: self.wizardContext.imapUsername];
        }
    }
}

@end
