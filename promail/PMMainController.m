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
#import "PMNewMailSheet.h"
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
        [self setBusyIndicatorVisible:NO];
        [self setStatusText:@""];
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
    
    [self registerAsObserver];
}


-(void) registerAsObserver{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(busyStatus:) name:PMStatusFetchMailBusy object:nil];
    [nc addObserver:self selector:@selector(busyStatus:) name:PMStatusFetchMailNotBusy object:nil];
}

-(void) busyStatus: (NSNotification *) notification{
    NSLog(@"boo, busy thingy");
    
    NSDictionary *userInfo = [notification valueForKey:@"userInfo"];
    
    BOOL isBusy = (BOOL)[userInfo valueForKey:@"busy"];
    if(isBusy){
        [self setStatusText: [userInfo valueForKey:@"busyText"]];
        [self setBusyIndicatorVisible:YES];
    }else{
        [self setStatusText:@""];
        [self setBusyIndicatorVisible:NO];
    }
}

-(void) clearStatus{
    /* TODO:
     currently the status is cleared everytime one of the accounts
     is finished. We need a smarter way for this.
     */
    [self setStatusText:@""];
    [self setBusyIndicatorVisible:NO];
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
    PMNewMailSheet *newMail = [[PMNewMailSheet alloc] init];
    [NSApp beginSheet:newMail.window modalForWindow:self.window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
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
