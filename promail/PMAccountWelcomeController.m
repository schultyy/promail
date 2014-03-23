//
//  PMAccountWelcomeController.m
//  promail
//
//  Created by Jan Schulte on 28/02/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMAccountWelcomeController.h"

@interface PMAccountWelcomeController ()

@end

@implementation PMAccountWelcomeController

-(id) initWithWizardContext:(PMAccountWizardContext *)wizardContext
{
    self = [super initWithWizardContext:wizardContext andNibName:@"PMAccountWelcomeView"];
    if (self) {
    }
    return self;
}

-(NSNumber *) order{
    return [NSNumber numberWithInt:1];
}

-(NSString *) title{
    return @"Welcome";
}

-(IBAction) changeAccountColor: (id) sender{
    [self setColor: self.colorWell.color];
    
    NSLog(@"Changed color: %@", self.colorWell.color);
}

-(BOOL) isValid{
    BOOL nameValid = [[self fullName] length] > 0;
    BOOL emailValid = [[self emailAddress] length] > 0;
    BOOL passwordValid = [[self password] length] > 0;
    
    return nameValid && emailValid && passwordValid;
}

-(BOOL) canActivate{
    return YES;
}

-(void) beforeNext{
    [[self wizardContext] setEmailAddress: self.emailAddress];
    [[self wizardContext] setFullName: self.fullName];
    [[self wizardContext] setAccountColor: self.color];
    [[self wizardContext] setImapPassword: self.password];
    [[self wizardContext] setSmtpPassword: self.password];
}

@end
