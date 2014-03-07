//
//  PMAccountDefault.m
//  promail
//
//  Created by Jan Schulte on 02/03/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMAccountDefault.h"

@implementation PMAccountDefault

-(id) init{
    self = [super init];
    if(self) {
        [self setCustomConfigurationEnabled:NO];
    }
    return self;
}

@end
