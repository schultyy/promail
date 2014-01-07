//
//  PMAccountsWindowController.m
//  promail
//
//  Created by Jan Schulte on 18/12/13.
//  Copyright (c) 2013 schultyy. All rights reserved.
//

#import "PMAccountsWindowController.h"
#import "PMConnectionType.h"
#import "SSKeychain.h"
#import "PMConstants.h"

@interface PMAccountsWindowController ()

@end

@implementation PMAccountsWindowController

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super initWithWindowNibName:@"AccountsWindow"];
    if (self) {
        [self setManagedObjectContext:context];
        [self setSelections: [[NSMutableIndexSet alloc]init]];
        
        id types = [[NSMutableArray alloc] init];
        
        [types addObject:[[PMConnectionType alloc] initWithName: @"STARTTLS" andKey: [NSNumber numberWithInt:0]]];
        [types addObject:[[PMConnectionType alloc] initWithName: @"TLS" andKey: [NSNumber numberWithInt:1]]];
        
        [self setConnectionTypes:types];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [[self window] setDelegate:self];
    [[self window] setBackgroundColor: [NSColor whiteColor]];
}

-(NSArray *) accounts{
    id fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity: [NSEntityDescription entityForName:@"Account"
                                         inManagedObjectContext: [self managedObjectContext]]];
    id context = [self managedObjectContext];
    NSError *error = nil;
    return [context executeFetchRequest:fetchRequest error:&error];
}

-(BOOL)windowShouldClose:(id)sender{
    
    NSError *error;
    
    [[self managedObjectContext] save: &error];
    return YES;
}

-(IBAction)setNewPassword:(id)sender{
    
    NSUInteger index = [[self selections] firstIndex];
    
    NSManagedObject *account = [[self accounts] objectAtIndex:index];
    
    [SSKeychain setPassword: [self password] forService:PMApplicationName account: [account valueForKey:@"email"]];
    
    [self setPassword:@""];
}

@end
