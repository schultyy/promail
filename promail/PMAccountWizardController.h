//
//  PMAccountWizardController.h
//  promail
//
//  Created by Jan Schulte on 28/02/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PMStepController.h"

@interface PMAccountWizardController : NSWindowController{
    NSArray *steps;
    NSUInteger nextStep;
}

-(id) initWithManagedObjectContext: (NSManagedObjectContext *) context;

@property IBOutlet NSBox *currentView;

//@property (assign) PMStepController *currentStep;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

-(BOOL) canProceed;

@end
