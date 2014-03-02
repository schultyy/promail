//
//  PMAccountIMAPViewController.m
//  promail
//
//  Created by Jan Schulte on 02/03/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMAccountIMAPViewController.h"
#import "PMAccountWizardContext.h"

@interface PMAccountIMAPViewController ()

@end

@implementation PMAccountIMAPViewController

-(id) initWithWizardContext:(PMAccountWizardContext *) wizardContext{
    self = [super initWithWizardContext: wizardContext];
    if(self){
        
    }
    return self;
}

-(NSString *) title{
    return @"IMAP Settings";
}

-(void) beforeNext{
    
}

@end
