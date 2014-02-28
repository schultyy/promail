//
//  PMStepController.h
//  promail
//
//  Created by Jan Schulte on 28/02/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*
 This class is meant to be abstract
 */

@interface PMStepController : NSViewController

-(NSString *) title;

-(NSNumber *) order;

-(BOOL) isValid;

@end
