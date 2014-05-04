//
// Created by Jan Schulte on 04/05/14.
// Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMFacade.h"


@implementation PMFacade

#pragma mark Initializers

-(id) initWitManagedObjectContext: (NSManagedObjectContext *) context {
    self = [super init];
    if(self) {
        managedObjectContext = context;
    }
    return self;
}

@end
