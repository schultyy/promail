//
//  PMAccountDefaultsManager.m
//  promail
//
//  Created by Jan Schulte on 02/03/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMAccountDefaultsManager.h"
#import "PMAccountDefault.h"

@implementation PMAccountDefaultsManager

+(PMAccountDefault *) SettingsForKey:(NSString *)key{
    
    if([key isEqualToString:@"gmail"]){
        return [PMAccountDefaultsManager gmail];
    }
    if([key isEqualToString:@"yahoo"]){
        [PMAccountDefaultsManager yahoo];
    }
    if([key isEqualToString:@"outlook"]){
        [PMAccountDefaultsManager outlook];
    }
    if([key isEqualToString:@"custom"]){
        [PMAccountDefaultsManager custom];
    }
    
    return nil;
}

+(PMAccountDefault *) gmail{
    PMAccountDefault *accountDefault = [[PMAccountDefault alloc] init];
    [accountDefault setAccountKey:@"gmail"];
    
    [accountDefault setImapEncryptionType:@"TLS"];
    [accountDefault setImapPort: [NSNumber numberWithInt:993]];
    [accountDefault setImapServer:@"imap.gmail.com"];
    
    [accountDefault setSmtpEncryptionType:@"TLS"];
    [accountDefault setSmtpPort: [NSNumber numberWithInt:465]];
    [accountDefault setSmtpServer:@"smtp.gmail.com"];
    
    return accountDefault;
}

+(PMAccountDefault *) outlook{
    PMAccountDefault *accountDefault = [[PMAccountDefault alloc] init];
    [accountDefault setAccountKey:@"outlook"];
    
    [accountDefault setImapEncryptionType:@"TLS"];
    [accountDefault setImapPort: [NSNumber numberWithInt:993]];
    [accountDefault setImapServer:@"imap-mail.outlook.com"];
    
    [accountDefault setSmtpEncryptionType:@"TLS"];
    [accountDefault setSmtpPort: [NSNumber numberWithInt:587]];
    [accountDefault setSmtpServer:@"smtp-mail.outlook.com"];
    
    return accountDefault;
}

+(PMAccountDefault *) yahoo{
    PMAccountDefault *accountDefault = [[PMAccountDefault alloc] init];
    [accountDefault setAccountKey:@"yahoo"];
    
    [accountDefault setImapEncryptionType:@"TLS"];
    [accountDefault setImapPort: [NSNumber numberWithInt:993]];
    [accountDefault setImapServer:@"imap.mail.yahoo.com"];
    
    [accountDefault setSmtpEncryptionType:@"TLS"];
    [accountDefault setSmtpPort: [NSNumber numberWithInt:465]];
    [accountDefault setSmtpServer:@"smtp.mail.yahoo.com"];
    
    return accountDefault;
}

+(PMAccountDefault *) custom{
    PMAccountDefault *accountDefault = [[PMAccountDefault alloc] init];
    [accountDefault setAccountKey:@"custom"];
    return accountDefault;
}

@end
