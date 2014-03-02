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

@property (retain) NSString *imapServer;

@property (retain) NSNumber *imapPort;

@property (assign) PMEncryptionType *encryptionType;

@property (retain) NSString *imapPassword;

-(id) initWithWizardContext:(PMAccountWizardContext *)wizardContext;

@end
