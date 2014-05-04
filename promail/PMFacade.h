//
// Created by Jan Schulte on 04/05/14.
// Copyright (c) 2014 schultyy. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PMFacade : NSObject{
    NSManagedObjectContext *managedObjectContext;
}

-(id) initWitManagedObjectContext: (NSManagedObjectContext *) context;


@end
