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
#import "PMMailHeaderViewController.h"

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

@property (retain) PMMailHeaderViewController *mailHeader;

@property (retain) NSManagedObject *currentMail;

@property (assign) BOOL isBusy;

@property IBOutlet NSBox *headerView;

@property IBOutlet PMMessageView *messageView;

@end
