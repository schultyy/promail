//
//  PMAccountDefaultsManager.h
//  promail
//
//  Created by Jan Schulte on 02/03/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMAccountDefault.h"

@interface PMAccountDefaultsManager : NSObject

+(PMAccountDefault *) SettingsForKey: (NSString *) key;

@end
