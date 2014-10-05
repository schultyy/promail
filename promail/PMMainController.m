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
#import "PMMailDetailWindowController.h"
#import "PMConstants.h"

@interface PMMainController ()

@end

@implementation PMMainController

- (id)initWithObjectContext:(NSManagedObjectContext *)context
{
    self = [super initWithWindowNibName:@"MainWindow"];
    if(self){
        [self setManagedObjectContext: context];
        [self setFolderList: [[PMFolderListController alloc] initWithObjectContext:context]];
        [self setMailDetail: [[PMMailDetailController alloc] init]];
        [self setAccountFacade:[[PMAccountFacade alloc] initWitManagedObjectContext:context]];
        [self setMailFacade: [[PMMailFacade alloc] initWitManagedObjectContext:context]];
        [self setBusyIndicatorVisible:NO];
        [self setStatusText:@""];
    }
    return self;
}

-(void) awakeFromNib{
    [[self window] setBackgroundColor: NSColor.whiteColor];
    [[self listView] setContentView: [[self folderList] view]];
    [self registerAsObserver];
}


-(void) registerAsObserver{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(showMessage:) name:PMShowMessageDetail object:nil];
    [nc addObserver:self selector:@selector(busyStatus:) name:PMStatusFetchMailBusy object:nil];
    [nc addObserver:self selector:@selector(busyStatus:) name:PMStatusFetchMailNotBusy object:nil];
}

-(void) busyStatus: (NSNotification *) notification{
    
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
    
-(void) showMessage: (NSNotification *) notification{
    [[self listView] setContentView: [self.mailDetail view]];
    
    NSManagedObject *mail = [[notification userInfo] valueForKey:@"message"];

    BOOL seen = [[mail valueForKey:@"seen"] boolValue];
    
    if(!seen){
        [[self mailFacade] mark: YES mail: mail finished:^ {
            [mail setValue: [NSNumber numberWithBool:YES] forKey:@"seen"];
        }];
    }
    [[self mailDetail] setCurrentMail:mail];
}

# pragma mark Toolbar Actions

-(void)refresh{
    [[self folderList] loadMails];
}

-(void) writeNew {
    if(![self composeMailEditor]) {
        [self setComposeMailEditor:[[PMMailDetailWindowController alloc] initWithManagedObjectContext:
         self.managedObjectContext]];
    }
    [[self composeMailEditor] showWindow:self];
}

-(void) navigateBack {
    [[self listView] setContentView: self.folderList.view];
}

#pragma mark Toolbar Delegate methods

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return [NSArray arrayWithObjects: PMToolbarNavigateBack, PMToolbarRefresh, PMToolbarWriteNew, nil];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return [NSArray arrayWithObjects: PMToolbarNavigateBack, PMToolbarRefresh, PMToolbarWriteNew, nil];
}

-(BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem{
    if([[toolbarItem itemIdentifier] isEqualToString: PMToolbarRefresh] ||
       [[toolbarItem itemIdentifier] isEqualToString: PMToolbarWriteNew]){

        if([[[self accountFacade] fetchAccounts] count] == 0) {
            return NO;
        }
    }
    else if([[toolbarItem itemIdentifier] isEqualToString:PMToolbarNavigateBack]) {
        if([[[self accountFacade] fetchAccounts] count] == 0) {
            return NO;
        }
        else if ([[[self listView] contentView] isEqual:self.folderList.view]){
            return NO;
        }
    }
    return YES;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
                            itemForItemIdentifier:(NSString *)itemIdentifier
                            willBeInsertedIntoToolbar:(BOOL)flag {
    if([itemIdentifier isEqualToString:PMToolbarRefresh]){
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
    else if([itemIdentifier isEqualToString:PMToolbarNavigateBack]) {
        NSToolbarItem *navigateBack = [[NSToolbarItem alloc] initWithItemIdentifier:PMToolbarNavigateBack];
        [navigateBack setTarget:self];
        [navigateBack setAction:@selector(navigateBack)];
        [navigateBack setLabel:@"Back"];
        [navigateBack setImage: [NSImage imageNamed:@"NSGoLeftTemplate"]];
        return navigateBack;
    }
    return nil;
}
@end
