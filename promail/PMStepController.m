//
//  PMStepController.m
//  promail
//
//  Created by Jan Schulte on 28/02/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMStepController.h"

@interface PMStepController ()

@end

@implementation PMStepController

-(id) initWithWizardContext:(PMAccountWizardContext *)wizardContext andNibName:(NSString *)nibName {
    self = [super initWithNibName:nibName bundle:nil];
    if(self){
        [self setWizardContext:wizardContext];
    }
    return self;
}

-(NSString *) title{
    return @"";
}

-(NSNumber *) order{
    return [NSNumber numberWithInt:-1];
}

-(BOOL)isValid{
    return NO;
}

-(BOOL) canActivate{
    return YES;
}

-(void) beforeNext{
}

-(void) activate{
}

@end
