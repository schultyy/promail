//
//  PMAccountVendorViewController.h
//  promail
//
//  Created by Jan Schulte on 02/03/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMStepController.h"
#import "PMAccountWizardContext.h"

@interface PMAccountVendorViewController : PMStepController

-(id) initWithWizardContext: (PMAccountWizardContext *) wizardContext;

@property (retain) NSArray *vendors;

@end
