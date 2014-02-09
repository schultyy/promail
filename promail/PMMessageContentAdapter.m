//
//  PMMessageContentAdapter.m
//  promail
//
//  Created by Jan Schulte on 09/02/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMMessageContentAdapter.h"
#import <MailCore/MailCore.h>

@implementation PMMessageContentAdapter

+(NSString *) convertMessage: (MCOAbstractMessage *) message withDelegate: (id) renderDelegate andFolder: (NSString *) folder{
    
    if (!message) {
        return nil;
    }
    
    if ([message isKindOfClass:[MCOIMAPMessage class]]) {
        return [(MCOIMAPMessage *) message htmlRenderingWithFolder:folder delegate:renderDelegate];
    }
    else if ([message isKindOfClass:[MCOMessageBuilder class]]) {
        return [(MCOMessageBuilder *) message htmlRenderingWithDelegate:renderDelegate];
    }
    else if ([message isKindOfClass:[MCOMessageParser class]]) {
        return [(MCOMessageParser *) message htmlRenderingWithDelegate:renderDelegate];
    }
    else {
        return nil;
        MCAssert(0);
    }
}

@end
