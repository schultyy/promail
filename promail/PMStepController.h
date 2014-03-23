//
//  PMStepController.h
//  promail
//
//  Created by Jan Schulte on 28/02/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PMAccountWizardContext.h"
/*
 This class is meant to be abstract
 */

@interface PMStepController : NSViewController

@property (assign) PMAccountWizardContext *wizardContext;

-(id) initWithWizardContext: (PMAccountWizardContext *) wizardContext andNibName: (NSString *) nibName;

-(NSString *) title;

-(BOOL) isValid;

/*
 This method is called *before* activate is called. The purpose of this method is to check if the current step can used
 for the set of defined settings (user input and defaults)
 */
-(BOOL) canActivate;

/*
 Do not call this method directly. This is called by the wizard itself when the step becomes the active step.
 */
-(void) activate;

/*
 Do not call this method directly. This is called by the wizard itself before the next step will be shown.
 Do clean up and save necessary information to the wizard context here.
 */
-(void) beforeNext;

@end
