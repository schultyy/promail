
//
//  PMNewMailSheet.m
//  promail
//
//  Created by Jan Schulte on 07/01/14.
//  Copyright (c) 2014 schultyy. All rights reserved.
//

#import "PMNewMailWindowController.h"

@interface PMNewMailWindowController()

@end

@implementation PMNewMailWindowController

-(id)initWithManagedObjectContext:(NSManagedObjectContext *)context {
    self = [super initWithWindowNibName:@"PMNewMailWindow"];
    if (self) {
        [self setManagedObjectContext:context];
        [self setMailFacade: [[PMMailFacade alloc] initWitManagedObjectContext: context]];
    }
    return self;
}

-(void) windowDidLoad{
    [[self window] setBackgroundColor: [NSColor whiteColor]];
}

-(IBAction)sendMail: (id) sender {
    NSArray *recipients = [NSArray arrayWithObject:self.to];

    [self.mailFacade sendMail: self.selectedAccount
                   recipients: recipients
                           cc:nil
                          bcc:nil
                      subject:self.subject
                         body:self.body];
    [self close];
}

-(IBAction)discard:(id)sender{
    [self close];
}

/*
From https://developer.apple.com/library/mac/qa/qa1454/_index.htmlg
 */
- (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector
{
    BOOL result = NO;

    if (commandSelector == @selector(insertNewline:))
    {
        // new line action:
        // always insert a line-break character and don’t cause the receiver to end editing
        [textView insertNewlineIgnoringFieldEditor:self];
        result = YES;
    }
    else if (commandSelector == @selector(insertTab:))
    {
        // tab action:
        // always insert a tab character and don’t cause the receiver to end editing
        [textView insertTabIgnoringFieldEditor:self];
        result = YES;
    }

    return result;
}

@end
