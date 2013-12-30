//
//  PMMainController.m
//  promail
//
//  Created by Jan Schulte on 10/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import "PMMainController.h"
#import "PMFolderListController.h"
#import "PMMailDetailController.h"
#import "PMConstants.h"

@interface PMMainController ()

@end

@implementation PMMainController

- (id)initWithObjectContext:(NSManagedObjectContext *)context
{
    self = [super initWithWindowNibName:@"MainWindow"];
    if(self){
        [self setFolderList: [[PMFolderListController alloc] initWithObjectContext:context]];
        [self setMailDetail: [[PMMailDetailController alloc] init]];
    }
    return self;
}

-(void) awakeFromNib{
    [[self window] setBackgroundColor: NSColor.whiteColor];
    
    [[self currentView] setContentView: [[self folderList] view]];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(showMessage:) name:PMShowMessageDetail object:nil];
}
    
-(void) showMessage: (NSNotification *) notification{
    [[self currentView] setContentView: [[self mailDetail] view]];
    
    NSManagedObject *mail = [notification valueForKey:@"message"];
    
    [[self mailDetail] setCurrentMail:mail];
}

-(IBAction)refresh:(id)sender{
    [[self folderList] loadMails];
}
@end
