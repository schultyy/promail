//
//  PMAccountProvider.h
//  promail
//
//  Created by Jan Schulte on 02/03/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMAccountProvider : NSObject

@property (retain) NSString *providerKey;

@property (retain) NSString *displayName;

-(id) initWithKey: (NSString *) key andDisplayName: (NSString *) displayName;

@end
