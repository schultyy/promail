//
//  PMAccountServerViewController.h
//  promail
//
//  Created by Jan Schulte on 28/02/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PMStepController.h"
#import "PMAccountWizardContext.h"

@interface PMAccountServerViewController : PMStepController

@property (retain) NSString *server;

@property (retain) NSNumber *port;

@property (assign) PMEncryptionType *encryptionType;

@property (retain) NSString *imapPassword;

@property (retain) NSString *username;

@property (retain) NSArray *connectionTypes;

-(id) initWithWizardContext:(PMAccountWizardContext *)wizardContext;

@end
