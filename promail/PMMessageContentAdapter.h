//
//  PMMessageContentAdapter.h
//  promail
//
//  Created by Jan Schulte on 09/02/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>

@interface PMMessageContentAdapter : NSObject

+(NSString *) convertMessage: (MCOAbstractMessage *) message withDelegate: (id) renderDelegate andFolder: (NSString *) folder;

@end
