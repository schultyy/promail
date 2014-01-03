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

-(void)refresh{
    [[self folderList] loadMails];
}

-(void) writeNew{
    
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return [NSArray arrayWithObjects:PMToolbarFolderList, PMToolbarRefresh, PMToolbarWriteNew, nil];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return [NSArray arrayWithObjects:PMToolbarFolderList, PMToolbarRefresh, PMToolbarWriteNew, nil];
}

-(BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem{
    if([[toolbarItem itemIdentifier] isEqualToString: PMToolbarRefresh]){
        if([[[self folderList] accounts] count] == 0){
            return NO;
        }
    }
    return YES;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
                            itemForItemIdentifier:(NSString *)itemIdentifier
                            willBeInsertedIntoToolbar:(BOOL)flag {

    if ([itemIdentifier isEqualToString:PMToolbarFolderList]) {
        NSToolbarItem *showFolderList = [[NSToolbarItem alloc] initWithItemIdentifier:PMToolbarFolderList];
        [showFolderList setTarget:self];
        [showFolderList setAction:@selector(showFolderList)];
        [showFolderList setLabel:@"Folder list"];
        [showFolderList setImage: [NSImage imageNamed:@"NSListViewTemplate"]];
        return showFolderList;
    }
    else if([itemIdentifier isEqualToString:PMToolbarRefresh]){
        NSToolbarItem *refresh = [[NSToolbarItem alloc] initWithItemIdentifier:PMToolbarRefresh];
        [refresh setTarget:self];
        [refresh setAction:@selector(refresh)];
        [refresh setLabel:@"Refresh"];
        [refresh setImage: [NSImage imageNamed:@"NSRefreshFreestandingTemplate"]];
        return refresh;
    }
    else if([itemIdentifier isEqualToString:PMToolbarWriteNew]){
        NSToolbarItem *writeNew = [[NSToolbarItem alloc] initWithItemIdentifier:PMToolbarWriteNew];
        [writeNew setTarget:self];
        [writeNew setAction:@selector(writeNew)];
        [writeNew setLabel:@"Write new"];
        [writeNew setImage: [NSImage imageNamed:@"NSAddTemplate"]];
        return writeNew;
    }
    return nil;
}
@end
