//
//  PMAccountProvider.m
//  promail
//
//  Created by Jan Schulte on 02/03/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMAccountProvider.h"

@implementation PMAccountProvider

-(id) initWithKey:(NSString *)key andDisplayName:(NSString *)displayName{
    self = [super init];
    if(self){
        [self setProviderKey:key];
        [self setDisplayName:displayName];
    }
    return self;
}

@end
