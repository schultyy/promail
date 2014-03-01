//
//  PMAccountWizardContext.h
//  promail
//
//  Created by Jan Schulte on 01/03/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    EncryptionTypeTLS = 1,
    EncryptionTypeSTARTTLS
}PMEncryptionType;

@interface PMAccountWizardContext : NSObject

@property (retain) NSString *emailAddress;
@property (retain) NSString *fullName;
@property (retain) NSString *imapPassword;
@property (retain) NSNumber *imapPort;
@property (retain) NSString *imapServer;
@property (retain) NSString *imapUsername;

@end
