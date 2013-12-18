//
//  PMMailController.h
//  promail
//
//  Created by Jan Schulte on 10/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>

@interface PMMailController : NSObject

-(void) fetchMails:(void (^)(NSError*, NSArray*, MCOIndexSet*))callbackBlock;

@end
