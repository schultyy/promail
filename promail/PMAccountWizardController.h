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

-(id) initWithManagedObjectContext: (NSManagedObjectContext *) context;

@property IBOutlet NSBox *currentView;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

-(BOOL) canProceed;

-(IBAction)nextStep:(id)sender;
-(IBAction)previousStep:(id)sender;

@end
