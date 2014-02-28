//
//  PMAccountWizardController.m
//  promail
//
//  Created by Jan Schulte on 28/02/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMAccountWizardController.h"
#import "PMStepController.h"
#import "PMAccountWelcomeController.h"

@interface PMAccountWizardController ()

@end

@implementation PMAccountWizardController

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super initWithWindowNibName:@"PMAccountWizardWindow"];
    if (self) {
        nextStep = 0;
    }
    return self;
}

-(void) windowDidLoad{
    [super windowDidLoad];
    [self initSteps];
    [self nextStep];
}

-(void) nextStep{
    PMStepController *currentStep = [steps objectAtIndex:nextStep];
    nextStep++;
    [[self currentView] setContentView: currentStep.view];
}

-(void) initSteps{
    NSMutableArray *controllers = [NSMutableArray array];
    
    [controllers addObject: [[PMAccountWelcomeController alloc] init]];
    
    steps = [NSArray arrayWithArray:controllers];
}

@end
