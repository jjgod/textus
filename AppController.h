//
//  AppController.h
//  Textus
//
//  Created by Jjgod Jiang on 3/16/09.
//  Copyright 2009 Jjgod Jiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppController : NSResponder {
    NSMutableDictionary *bookmarksDictionary;
}

- (NSFont *) font;
- (NSColor *) foregroundColor;
- (NSColor *) backgroundColor;
- (IBAction) addBookmark: (id) sender;
- (IBAction) gotoBookmark: (id) sender;

@end
