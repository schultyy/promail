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
    
    NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] init];
    [toolbarItem setLabel:@"Folder list"];
    [toolbarItem setAction:@selector(showFolderList)];
    [toolbarItem setTarget:self];
}

-(void) showFolderList{
    [[self mailDetail] resetView];
    [[self currentView] setContentView: [[self folderList] view]];
}
    
-(void) showMessage: (NSNotification *) notification{
    [[self currentView] setContentView: [[self mailDetail] view]];
    
    NSManagedObject *mail = [[notification userInfo] valueForKey:@"message"];
    
    [[self mailDetail] setCurrentMail:mail];
}

-(IBAction)refresh:(id)sender{
    [[self folderList] loadMails];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return [NSArray arrayWithObject:PMToolbarFolderList];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return [NSArray arrayWithObject:PMToolbarFolderList];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
                            itemForItemIdentifier:(NSString *)itemIdentifier
                            willBeInsertedIntoToolbar:(BOOL)flag {

    if ([itemIdentifier isEqualToString:PMToolbarFolderList]) {
        NSToolbarItem *showFolderList = [[NSToolbarItem alloc] initWithItemIdentifier:PMToolbarFolderList];
        [showFolderList setTarget:self];
        [showFolderList setAction:@selector(showFolderList)];
        [showFolderList setLabel:@"Folder list"];
        return showFolderList;
    }
    return nil;
}
@end
