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

@property (assign) PMEncryptionType encryptionType;

@property (retain) NSString *password;

@property (retain) NSString *username;

@property (retain) NSArray *connectionTypes;

@property (retain) NSIndexSet *selections;

-(id) initWithWizardContext:(PMAccountWizardContext *)wizardContext;

@end
