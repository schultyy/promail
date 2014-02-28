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

- (id)init
{
    self = [super initWithNibName:@"PMAccountWelcomeView" bundle:nil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(NSNumber *) order{
    return [NSNumber numberWithInt:1];
}

-(NSString *) title{
    return @"Welcome";
}

@end
