//
//  PMAccountWizardContext.h
//  promail
//
//  Created by Jan Schulte on 01/03/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMAccountDefault.h"

typedef enum{
    EncryptionTypeTLS = 1,
    EncryptionTypeSTARTTLS
}PMEncryptionType;

@interface PMAccountWizardContext : NSObject

@property (retain) NSString *emailAddress;
@property (retain) NSString *fullName;

#pragma mark IMAP

@property (retain) NSString *imapPassword;
@property (retain) NSNumber *imapPort;
@property (retain) NSString *imapServer;
@property (retain) NSString *imapUsername;
@property (assign) PMEncryptionType imapEncryption;

#pragma mark SMTP

@property (retain) NSString *smtpPassword;
@property (retain) NSNumber *smtpPort;
@property (retain) NSString *smtpServer;
@property (retain) NSString *smtpUsername;
@property (assign) PMEncryptionType smtpEncryption;

-(void) copyFromDefaults: (PMAccountDefault *) defaults;

@end
