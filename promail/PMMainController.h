//
//  PMMainController.h
//  promail
//
//  Created by Jan Schulte on 10/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PMMailController.h"

@interface PMMainController : NSWindowController

@property (retain) NSMutableArray *mails;

@property (retain) PMMailController *mailController;

@end
