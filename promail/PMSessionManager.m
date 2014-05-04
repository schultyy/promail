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
        [self initializeIMAPSession];
        [self initializeSMTPSession];
    }
    return self;
}

-(void) initializeIMAPSession{
    imapSession = [[MCOIMAPSession alloc] init];
    imapSession.hostname = [account valueForKey:@"imapServer"];
    NSInteger num = [[account valueForKey:@"imapPort"] integerValue];
    imapSession.port = num;
    imapSession.username = [account valueForKey:@"imapUsername"];
    imapSession.password = [self fetchPassword: [account valueForKey: @"email"]];
    int connectionType = [[account valueForKey:@"imapEncryption"] intValue];
    switch (connectionType) {
        case 0:
            imapSession.connectionType = MCOConnectionTypeStartTLS;
            break;
        case 1:
            imapSession.connectionType = MCOConnectionTypeTLS;
            break;
        default:
            NSLog(@"Invalid transport security option %li", (long) connectionType);
            break;
    }
}

-(void)initializeSMTPSession {
    smtpSession = [[MCOSMTPSession alloc] init];
    smtpSession.hostname = [account valueForKey:@"smtpServer"];
    NSInteger num = [[account valueForKey:@"smtpPort"] integerValue];
    smtpSession.port = num;
    smtpSession.username = [account valueForKey:@"smtpUsername"];
    smtpSession.password = [self fetchPassword: [account valueForKey: @"email"]];
    int connectionType = [[account valueForKey:@"smtpEncryption"] intValue];
    switch (connectionType) {
        case 0:
            smtpSession.connectionType = MCOConnectionTypeStartTLS;
            break;
        case 1:
            smtpSession.connectionType = MCOConnectionTypeTLS;
            break;
        default:
            NSLog(@"Invalid transport security option %li", (long) connectionType);
            break;
    }
}

-(NSString *) fetchPassword: (NSString *) email{
    return [SSKeychain passwordForService:PMApplicationName account:email];
}

-(void) fetchBodyForMessage: (NSNumber *) uid completionBlock: (void (^)(NSError *error, NSData *data)) completionBlock{

    MCOIMAPFetchContentOperation * fetchOperation = [imapSession fetchMessageByUIDOperationWithFolder:@"INBOX" uid:uid.unsignedIntValue];
    [fetchOperation start: completionBlock];
}

-(void) fetchFlagsAndUIDsForFolder: (NSString *) folder completionBlock: (void (^)(NSError * error, NSArray * messages, MCOIndexSet * vanishedMessages))completionBlock{

    MCOIndexSet *uidSet = [MCOIndexSet indexSetWithRange:MCORangeMake(1,UINT64_MAX)];

    MCOIMAPFetchMessagesOperation *fetchOperation =
            [imapSession fetchMessagesByUIDOperationWithFolder:folder
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

    MCOIMAPCapabilityOperation * op = [imapSession capabilityOperation];
    [op start:^(NSError * error, MCOIndexSet * capabilities) {
        BOOL isGmail = NO;
        if ([capabilities containsIndex:MCOIMAPCapabilityGmail]) {
            isGmail = YES;
        }
        MCOIMAPMessagesRequestKind kind = MCOIMAPMessagesRequestKindUid |
                MCOIMAPMessagesRequestKindFullHeaders |
                MCOIMAPMessagesRequestKindStructure |
                MCOIMAPMessagesRequestKindFlags |
                MCOIMAPMessagesRequestKindInternalDate;

        if (isGmail) {
            kind |= MCOIMAPMessagesRequestKindGmailLabels |
                    MCOIMAPMessagesRequestKindGmailThreadID |
                    MCOIMAPMessagesRequestKindGmailMessageID;
        }

        MCOIMAPFetchMessagesOperation *fetchOperation =
                [imapSession fetchMessagesByUIDOperationWithFolder:folder
                                                   requestKind:kind
                                                          uids:uidSet];

        [fetchOperation start: completionBlock];
    }];

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

    MCOIMAPOperation *op = [imapSession storeFlagsOperationWithFolder:@"INBOX"
                                                             uids:[MCOIndexSet indexSetWithIndex:uid.longValue]
                                                             kind:MCOIMAPStoreFlagsRequestKindSet
                                                            flags:flag];

    [op start: completionBlock];
}

-(void) sendMail: (NSArray *) recipients
              cc: (NSArray *) cc
             bcc: (NSArray *) bcc
         subject: (NSString *) subject
            body: (NSString *) body {

    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    [[builder header] setFrom:[MCOAddress addressWithDisplayName:nil mailbox: [account valueForKey:@"email"]]];
    NSMutableArray *to = [[NSMutableArray alloc] init];
    for(NSString *toAddress in recipients) {
        MCOAddress *newAddress = [MCOAddress addressWithMailbox:toAddress];
        [to addObject:newAddress];
    }
    [[builder header] setTo:to];
    NSMutableArray *ccList = [[NSMutableArray alloc] init];
    for(NSString *ccAddress in cc) {
        MCOAddress *newAddress = [MCOAddress addressWithMailbox:ccAddress];
        [ccList addObject:newAddress];
    }
    [[builder header] setCc:ccList];
    NSMutableArray *bccList = [[NSMutableArray alloc] init];
    for(NSString *bccAddress in bcc) {
        MCOAddress *newAddress = [MCOAddress addressWithMailbox:bccAddress];
        [bccList addObject:newAddress];
    }
    [[builder header] setBcc:bccList];
    [[builder header] setSubject:subject];
    [builder setHTMLBody:body];
    NSData * rfc822Data = [builder data];

    MCOSMTPSendOperation *sendOperation = [smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if(error) {
            NSLog(@"%@ Error sending email:%@", [account valueForKey:@"email"], error);
        } else {
            NSLog(@"%@ Successfully sent email!", [account valueForKey:@"email"]);
        }
    }];
}

@end
