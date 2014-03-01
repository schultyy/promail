//
//  PMAccountServerViewController.m
//  promail
//
//  Created by Jan Schulte on 28/02/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMAccountIMAPViewController.h"

@interface PMAccountIMAPViewController ()

@end

@implementation PMAccountIMAPViewController

- (id)init
{
    self = [super initWithNibName:@"PMAccountIMAPView" bundle:nil];
    if (self) {
    }
    return self;
}

-(NSString *) title{
    return @"Server settings";
}

-(NSNumber *) order{
    return [NSNumber numberWithInt:2];
}

@end
