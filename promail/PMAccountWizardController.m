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
#import "PMAccountFinishViewController.h"
#import "PMAccountWizardContext.h"
#import "PMConstants.h"
#import "SSKeychain.h"

@interface PMAccountWizardController ()

@end

@implementation PMAccountWizardController

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super initWithWindowNibName:@"PMAccountWizardWindow"];
    if (self) {
        nextStepIndex = 0;
        [self setManagedObjectContext:context];
        wizardContext = [[PMAccountWizardContext alloc] init];
        [self setNextButtonTitle:@"Next"];
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

-(PMStepController *) lastStep{
    return [steps lastObject];
}

-(IBAction)nextStep:(id)sender{
    [self nextStepHandler];
}

-(IBAction)previousStep:(id)sender{
    [self previousStepHandler];
}

-(void) nextStepHandler{
    if([self canGoNext]){
        
        [[self currentStep] beforeNext];
        
        nextStepIndex++;
        PMStepController *currentStep = [self currentStep];
        if([currentStep canActivate]){
            [[self currentView] setContentView: currentStep.view];
            [self setStepTitle: currentStep.title];
            [currentStep activate];
            if([currentStep isEqualTo: [self lastStep]]){
                [self setNextButtonTitle:@"Finish"];
            }
        }
        else{
            [self nextStepHandler];
        }
    }
    else{
        [self finish];
        [self close];
    }
}

-(void) finish {
    NSManagedObject *newAccount = [NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:self.managedObjectContext];
    [newAccount setValue: wizardContext.fullName forKey:@"name"];
    [newAccount setValue: wizardContext.emailAddress forKey:@"email"];
    
    [newAccount setValue: [NSNumber numberWithInt:wizardContext.smtpEncryption ] forKey:@"smtpEncryption"];
    [newAccount setValue: wizardContext.smtpPort forKey:@"smtpPort"];
    [newAccount setValue: wizardContext.smtpServer forKey:@"smtpServer"];
    
    [newAccount setValue: [NSNumber numberWithInt:wizardContext.imapEncryption ] forKey:@"imapEncryption"];
    [newAccount setValue: wizardContext.imapPort forKey:@"imapPort"];
    [newAccount setValue: wizardContext.imapServer forKey:@"imapServer"];
    
    [SSKeychain setPassword: wizardContext.imapPassword forService:PMApplicationName account: wizardContext.emailAddress];
    
    [[self managedObjectContext] save:nil];
}

-(void) previousStepHandler{
    
    //A bit hacky, to set this every time, but because of recursion not so easy
    //to transfer this state through all calls
    [self setNextButtonTitle:@"Next"];
    
    if([self canGoPrevious]){
        nextStepIndex--;
        PMStepController *currentStep = [self currentStep];
        if([currentStep canActivate]){
            [[self currentView] setContentView: currentStep.view];
            [self setStepTitle: currentStep.title];
            [currentStep activate];
        }
        else{
            [self previousStepHandler];
        }
    }
}

-(void) initSteps{
    NSMutableArray *controllers = [NSMutableArray array];
    
    [controllers addObject: [[PMAccountProviderViewController alloc] initWithWizardContext: wizardContext]];
    [controllers addObject: [[PMAccountWelcomeController alloc] initWithWizardContext:wizardContext]];
    [controllers addObject: [[PMAccountIMAPViewController alloc] initWithWizardContext:wizardContext]];
    [controllers addObject: [[PMAccountSMTPViewController alloc] initWithWizardContext:wizardContext]];
    [controllers addObject: [[PMAccountFinishViewController alloc] initWithWizardContext: wizardContext]];
    
    //Sort steps after the result of their order method
    steps = controllers;
    
    [self setStepTitle: self.currentStep.title];
    [[self currentStep] activate];
    
    [[self currentView] setContentView: [self currentStep].view];
}

-(BOOL) canProceed{
    return [[self currentStep] isValid];
}

@end
