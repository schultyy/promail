//
//  PMAccountWizardController.m
//  promail
//
//  Created by Jan Schulte on 28/02/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMAccountWizardController.h"
#import "PMStepController.h"
#import "PMAccountProviderViewController.h"
#import "PMAccountWelcomeController.h"
#import "PMAccountIMAPViewController.h"
#import "PMAccountSMTPViewController.h"
#import "PMAccountWizardContext.h"

@interface PMAccountWizardController ()

@end

@implementation PMAccountWizardController

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super initWithWindowNibName:@"PMAccountWizardWindow"];
    if (self) {
        nextStepIndex = 0;
        wizardContext = [[PMAccountWizardContext alloc] init];
    }
    return self;
}

-(void) awakeFromNib{
    [super awakeFromNib];
    [self initSteps];
}

#pragma mark Guards

-(BOOL) canGoNext{
    return nextStepIndex + 1 <= ([steps count] -1);
}

-(BOOL) canGoPrevious{
    return nextStepIndex > 0;
}

# pragma mark Step handling

-(PMStepController *) currentStep{
    return [steps objectAtIndex:nextStepIndex];
}

-(IBAction)nextStep:(id)sender{
    if([self canGoNext]){
        
        [[self currentStep] beforeNext];
        
        nextStepIndex++;
        PMStepController *currentStep = [self currentStep];
        [[self currentView] setContentView: currentStep.view];
        [self setStepTitle: currentStep.title];
    }
}

-(IBAction)previousStep:(id)sender{
    if([self canGoPrevious]){
        nextStepIndex--;
        PMStepController *currentStep = [self currentStep];
        [[self currentView] setContentView: currentStep.view];
        [self setStepTitle: currentStep.title];
    }
}

-(void) initSteps{
    NSMutableArray *controllers = [NSMutableArray array];
    
    [controllers addObject: [[PMAccountProviderViewController alloc] initWithWizardContext: wizardContext]];
    [controllers addObject: [[PMAccountWelcomeController alloc] initWithWizardContext:wizardContext]];
    [controllers addObject: [[PMAccountIMAPViewController alloc] initWithWizardContext:wizardContext]];
    [controllers addObject: [[PMAccountSMTPViewController alloc] initWithWizardContext:wizardContext]];
    
    //Sort steps after the result of their order method
    steps = controllers;
    
    [self setStepTitle: self.currentStep.title];
    
    [[self currentView] setContentView: [self currentStep].view];
}

-(BOOL) canProceed{
    return [[self currentStep] isValid];
}

@end
