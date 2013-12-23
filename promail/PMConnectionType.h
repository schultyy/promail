//
//  PMConnectionType.h
//  promail
//
//  Created by Jan Schulte on 23/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMConnectionType : NSObject

@property (retain) NSString *name;

@property (retain) NSNumber *key;

-(id) initWithName: (NSString *) name andKey: (NSNumber *) number;

@end
