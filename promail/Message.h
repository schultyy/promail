//
//  Message.h
//  promail
//
//  Created by Jan Schulte on 04/05/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSNumber * attachment_count;
@property (nonatomic, retain) NSString * bcc;
@property (nonatomic, retain) NSData * body;
@property (nonatomic, retain) NSString * cc;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSNumber * gmail_message_id;
@property (nonatomic, retain) NSNumber * gmail_thread_id;
@property (nonatomic, retain) NSString * message_id;
@property (nonatomic, retain) NSDate * received;
@property (nonatomic, retain) NSNumber * seen;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSString * to;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSManagedObject *account;
@property (nonatomic, retain) NSSet *gmail_labels;
@property (nonatomic, retain) NSManagedObject *thread;

-(NSString *) accountName;
@end

@interface Message (CoreDataGeneratedAccessors)

- (void)addGmail_labelsObject:(NSManagedObject *)value;
- (void)removeGmail_labelsObject:(NSManagedObject *)value;
- (void)addGmail_labels:(NSSet *)values;
- (void)removeGmail_labels:(NSSet *)values;

@end
