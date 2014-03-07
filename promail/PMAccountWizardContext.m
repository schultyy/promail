//
//  PMAccountWizardContext.m
//  promail
//
//  Created by Jan Schulte on 01/03/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMAccountWizardContext.h"

@implementation PMAccountWizardContext

-(void) copyFromDefaults: (PMAccountDefault *) defaults{
    [self setImapPort: defaults.imapPort];
    [self setImapServer:defaults.imapServer];
    
    if ([[[defaults imapEncryptionType] uppercaseString] isEqualToString:@"TLS"]){
        [self setImapEncryption: EncryptionTypeTLS];
    }
    else if([[[defaults imapEncryptionType] uppercaseString] isEqualToString:@"STARTTLS"]){
        [self setImapEncryption: EncryptionTypeSTARTTLS];
    }
    
    [self setSmtpPort: defaults.smtpPort];
    [self setSmtpServer: defaults.smtpServer];

    if ([[[defaults smtpEncryptionType] uppercaseString] isEqualToString:@"TLS"]){
        [self setSmtpEncryption: EncryptionTypeTLS];
    }
    else if([[[defaults smtpEncryptionType] uppercaseString] isEqualToString:@"STARTTLS"]){
        [self setSmtpEncryption: EncryptionTypeSTARTTLS];
    }
}

@end
