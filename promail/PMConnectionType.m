//
//  PMConnectionType.m
//  promail
//
//  Created by Jan Schulte on 23/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import "PMConnectionType.h"

@implementation PMConnectionType

-(id) initWithName: (NSString *) name andKey: (NSNumber *) key{
    self = [super init];
    if(self){
        [self setName: name];
        [self setKey:  key];
    }
    return self;
}

@end
