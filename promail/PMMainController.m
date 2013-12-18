//
//  PMMainController.m
//  promail
//
//  Created by Jan Schulte on 10/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import "PMMainController.h"

@interface PMMainController ()

@end

@implementation PMMainController

- (id)init
{
    self = [super initWithWindowNibName:@"MainWindow"];
    if(self){
        [self setMailController: [[PMMailController alloc] init]];
        [self setMails: [NSMutableArray array]];
    }
    return self;
}

-(void)awakeFromNib{
    [[self mailController]  fetchMails:^(NSError *error, NSArray *msgs, MCOIndexSet *vanished) {
        
    }];
}

@end
