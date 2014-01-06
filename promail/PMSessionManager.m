//
//  PMSessionManager.m
//  promail
//
//  Created by Jan Schulte on 30/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import "PMSessionManager.h"
#import "SSKeychain.h"
#import "PMConstants.h"

@implementation PMSessionManager

-(id) initWithAccount: (NSManagedObject *) acc{
    self = [super init];
    if(self){
        account = acc;
        [self initializeSession];
    }
    return self;
}

-(void) initializeSession{
    session = [[MCOIMAPSession alloc] init];
    session.hostname = [account valueForKey:@"server"];
    NSInteger num = [[account valueForKey:@"port"] integerValue];
    session.port = num;
    session.username = [account valueForKey:@"email"];
    session.password = [self fetchPassword: [account valueForKey: @"email"]];
    int connectionType = [[account valueForKey:@"encryption"] intValue];
    switch (connectionType) {
        case 0:
            session.connectionType = MCOConnectionTypeStartTLS;
            break;
        case 1:
            session.connectionType = MCOConnectionTypeTLS;
            break;
        default:
            NSLog(@"Invalid option %li", (long) connectionType);
            break;
    }
}

-(NSString *) fetchPassword: (NSString *) email{
    return [SSKeychain passwordForService:PMApplicationName account:email];
}

-(void) fetchBodyForMessage: (NSNumber *) uid completionBlock: (void (^)(NSError *error, NSData *data)) completionBlock{
    
    MCOIMAPFetchContentOperation * fetchOperation = [session fetchMessageByUIDOperationWithFolder:@"INBOX" uid:uid.unsignedIntValue];
    [fetchOperation start: completionBlock];
}

-(void) fetchFlagsAndUIDsForFolder: (NSString *) folder completionBlock: (void (^)(NSError * error, NSArray * messages, MCOIndexSet * vanishedMessages))completionBlock{
    
     MCOIndexSet *uidSet = [MCOIndexSet indexSetWithRange:MCORangeMake(1,UINT64_MAX)];
    
    MCOIMAPFetchMessagesOperation *fetchOperation =
    [session fetchMessagesByUIDOperationWithFolder:folder
                                       requestKind:(MCOIMAPMessagesRequestKindFlags | MCOIMAPMessagesRequestKindFlags)
                                              uids:uidSet];
    [fetchOperation start: completionBlock];
}

-(void) fetchMessagesForFolder: (NSString *) folder lastUID: (NSNumber *) lastUID completionBlock: (void (^)(NSError * error, NSArray * messages, MCOIndexSet * vanishedMessages))completionBlock{
    MCOIndexSet *uidSet = nil;
    if (lastUID) {
        uidSet = [MCOIndexSet indexSetWithRange:MCORangeMake([lastUID longValue], UINT64_MAX)];
    }
    else{
        uidSet = [MCOIndexSet indexSetWithRange:MCORangeMake(1,UINT64_MAX)];
    }
    
    MCOIMAPFetchMessagesOperation *fetchOperation =
    [session fetchMessagesByUIDOperationWithFolder:folder
                                       requestKind:MCOIMAPMessagesRequestKindFullHeaders |
                                                    MCOIMAPMessagesRequestKindStructure |
                                                    MCOIMAPMessagesRequestKindFlags
                                              uids:uidSet];
    
    [fetchOperation start: completionBlock];
}

-(NSString *) htmlBodyFromMessage: (NSData *)message{
    MCOMessageParser *messageParser = [[MCOMessageParser alloc] initWithData:message];
    
    return [messageParser htmlBodyRendering];
}

-(NSNumber *) lastUID {
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    
    NSArray *messages = [[[account valueForKey:@"messages"] allObjects] sortedArrayUsingDescriptors:sortDescriptors];
    return [[messages firstObject] valueForKey:@"uid"];
}

-(void) markSeen:(NSNumber *)uid Seen: (BOOL) isSeen completionBlock: (void (^)(NSError *error)) completionBlock{

    MCOMessageFlag flag = isSeen ? MCOMessageFlagSeen : MCOMessageFlagNone;
    
    MCOIMAPOperation *op = [session storeFlagsOperationWithFolder:@"INBOX"
                                                             uids:[MCOIndexSet indexSetWithIndex:uid.longValue]
                                                             kind:MCOIMAPStoreFlagsRequestKindSet
                                                            flags:flag];

    [op start: completionBlock];
}

@end
