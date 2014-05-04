//
// Created by Jan Schulte on 04/05/14.
// Copyright (c) 2014 schultyy. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PMMailFacade : NSObject {
    NSManagedObjectContext *managedObjectContext;
}

-(id) initWitManagedObjectContext: (NSManagedObjectContext *) context;

-(NSManagedObject *) createNewMessage;

-(void)processMessages: (NSArray *) newMails forAccount: (NSManagedObject *) account;

@end