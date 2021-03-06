//
//  PMAccountDefault.h
//  promail
//
//  Created by Jan Schulte on 02/03/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMAccountDefault : NSObject

@property (retain) NSString *accountKey;

@property (retain) NSString *imapServer;

@property (retain) NSNumber *imapPort;

@property (retain) NSString *imapEncryptionType;

@property (retain) NSString *smtpServer;

@property (retain) NSNumber *smtpPort;

@property (retain) NSString *smtpEncryptionType;

/*
 Describes, if the user can configure IMAP/SMTP settings or if they're
 predefined.
 This is NO by default
 */
@property (assign) BOOL customConfigurationEnabled;

@end
