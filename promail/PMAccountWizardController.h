//
//  PMAccountWizardController.h
//  promail
//
//  Created by Jan Schulte on 28/02/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PMStepController.h"
#import "PMAccountWizardContext.h"

@interface PMAccountWizardController : NSWindowController{
    NSArray *steps;
    NSUInteger nextStepIndex;
    PMAccountWizardContext *wizardContext;
}

@property IBOutlet NSBox *currentView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (assign) NSString *stepTitle;
@property (retain) NSString *nextButtonTitle;

-(id) initWithManagedObjectContext: (NSManagedObjectContext *) context;
-(PMStepController *) currentStep;
-(BOOL) canProceed;
-(IBAction)nextStep:(id)sender;
-(IBAction)previousStep:(id)sender;

@end
