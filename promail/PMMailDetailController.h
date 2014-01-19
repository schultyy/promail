//
//  PMMailDetailController.h
//  promail
//
//  Created by Jan Schulte on 24/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "PMMessageView.h"

@interface PMMailDetailController : NSViewController{
    NSMutableDictionary * _storage;
    NSMutableSet * _pending;
    NSMutableArray * _ops;
    MCOIMAPSession * _session;
    MCOIMAPMessage * _message;
    NSMutableDictionary * _callbacks;
    NSString * _folder;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (retain) NSManagedObject *currentMail;

@property (assign) BOOL isBusy;

@property (retain) PMMessageView *messageView;

@end
