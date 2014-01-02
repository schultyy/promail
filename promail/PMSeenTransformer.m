//
//  PMSeenTransformer.m
//  promail
//
//  Created by Jan Schulte on 02/01/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMSeenTransformer.h"

@implementation PMSeenTransformer


+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    
    if([[value stringValue] isEqualToString:@"0"]){
        return @"unseen";
    }
    return @"seen";
}

@end
