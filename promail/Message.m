//
//  Message.m
//  promail
//
//  Created by Jan Schulte on 04/05/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "Message.h"


@implementation Message

@dynamic attachment_count;
@dynamic bcc;
@dynamic body;
@dynamic cc;
@dynamic date;
@dynamic from;
@dynamic gmail_message_id;
@dynamic gmail_thread_id;
@dynamic message_id;
@dynamic received;
@dynamic seen;
@dynamic subject;
@dynamic to;
@dynamic uid;
@dynamic account;
@dynamic gmail_labels;
@dynamic thread;

-(NSString *) subjectTeaser {
    if([[self subject] length] > 60) {
        return [[[self subject] substringToIndex:60] stringByAppendingString:@"..."];
    }
    else {
        return [self subject];
    }
}

-(NSString *) accountName {
    return [[self valueForKey:@"account"] valueForKey:@"name"];
}

@end
