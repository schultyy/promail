//
//  PMMailDetailController.h
//  promail
//
//  Created by Jan Schulte on 24/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PMMailDetailController : NSViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (retain) NSManagedObject *currentMail;

@property (assign) BOOL isBusy;

@end
