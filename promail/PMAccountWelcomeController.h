//
//  PMAccountWelcomeController.h
//  promail
//
//  Created by Jan Schulte on 28/02/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PMStepController.h"

@interface PMAccountWelcomeController : PMStepController

@property (retain) NSString *fullName;

@property (retain) NSString *emailAddress;

@property (retain) NSString *password;

-(id) initWithWizardContext:(PMAccountWizardContext *) wizardContext;

@end
