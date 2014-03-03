//
//  PMAccountDefaultsManager.m
//  promail
//
//  Created by Jan Schulte on 02/03/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMAccountDefaultsManager.h"
#import "PMAccountDefault.h"
#import "PMConstants.h"

@implementation PMAccountDefaultsManager

+(PMAccountDefault *) SettingsForKey:(NSString *)key{
    
    if([key isEqualToString: PMAccountDefaultGmail]){
        return [PMAccountDefaultsManager gmail];
    }
    if([key isEqualToString:PMAccountDefaultYahoo]){
        return [PMAccountDefaultsManager yahoo];
    }
    if([key isEqualToString: PMAccountDefaultOutlook]){
        return [PMAccountDefaultsManager outlook];
    }
    if([key isEqualToString: PMAccountDefaultCustom]){
        return [PMAccountDefaultsManager custom];
    }
    
    return nil;
}

+(PMAccountDefault *) gmail{
    PMAccountDefault *accountDefault = [[PMAccountDefault alloc] init];
    [accountDefault setAccountKey: PMAccountDefaultGmail];
    
    [accountDefault setImapEncryptionType:@"TLS"];
    [accountDefault setImapPort: [NSNumber numberWithInt:993]];
    [accountDefault setImapServer:@"imap.gmail.com"];
    
    [accountDefault setSmtpEncryptionType:@"TLS"];
    [accountDefault setSmtpPort: [NSNumber numberWithInt:465]];
    [accountDefault setSmtpServer:@"smtp.gmail.com"];
    
    [accountDefault setUseEmailAsUsername: YES];
    
    return accountDefault;
}

+(PMAccountDefault *) outlook{
    PMAccountDefault *accountDefault = [[PMAccountDefault alloc] init];
    [accountDefault setAccountKey: PMAccountDefaultOutlook];
    
    [accountDefault setImapEncryptionType:@"TLS"];
    [accountDefault setImapPort: [NSNumber numberWithInt:993]];
    [accountDefault setImapServer:@"imap-mail.outlook.com"];
    
    [accountDefault setSmtpEncryptionType:@"TLS"];
    [accountDefault setSmtpPort: [NSNumber numberWithInt:587]];
    [accountDefault setSmtpServer:@"smtp-mail.outlook.com"];
    
    [accountDefault setUseEmailAsUsername: YES];
    
    return accountDefault;
}

+(PMAccountDefault *) yahoo{
    PMAccountDefault *accountDefault = [[PMAccountDefault alloc] init];
    [accountDefault setAccountKey: PMAccountDefaultYahoo];
    
    [accountDefault setImapEncryptionType:@"TLS"];
    [accountDefault setImapPort: [NSNumber numberWithInt:993]];
    [accountDefault setImapServer:@"imap.mail.yahoo.com"];
    
    [accountDefault setSmtpEncryptionType:@"TLS"];
    [accountDefault setSmtpPort: [NSNumber numberWithInt:465]];
    [accountDefault setSmtpServer:@"smtp.mail.yahoo.com"];
    
    [accountDefault setUseEmailAsUsername: YES];
    
    return accountDefault;
}

+(PMAccountDefault *) custom{
    PMAccountDefault *accountDefault = [[PMAccountDefault alloc] init];
    [accountDefault setAccountKey: PMAccountDefaultCustom];
    [accountDefault setUseEmailAsUsername: NO];
    return accountDefault;
}

@end
