//
//  PMMailDetailController.m
//  promail
//
//  Created by Jan Schulte on 24/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import "PMMailDetailController.h"
#import "PMSessionManager.h"
#import <MailCore/MailCore.h>

@interface PMMailDetailController ()

@end

@implementation PMMailDetailController

- (id)init
{
    self = [super initWithNibName:@"PMMailDetailView" bundle:nil];
    if (self) {
    }
    return self;
}

-(void) awakeFromNib{
    [self addObserver:self forKeyPath:@"currentMail" options:NSKeyValueObservingOptionNew context:nil];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"currentMail"]){
        NSString *bodyText = [[self currentMail] valueForKey:@"body"];
        if(!bodyText){
            [self fetchBodyText];
        }
    }
}

-(void) fetchBodyText{
    [self setIsBusy:YES];
    
    NSManagedObject *account = [[self currentMail] valueForKey:@"account"];
    NSNumber *uid = [[self currentMail] valueForKey:@"uid"];
    
    PMSessionManager *sessionManager = [[PMSessionManager alloc] initWithAccount:account];
    [sessionManager fetchBodyForMessage: uid completionBlock:^(NSError *error, NSData *data) {
        [self setIsBusy:NO];
        
        NSString *bodyText = [sessionManager htmlBodyFromMessage:data];
        
        [[self currentMail] setValue:bodyText forKey:@"body"];

        [[[self webview] mainFrame] loadHTMLString:bodyText baseURL:nil];
    }];
    
}

@end
