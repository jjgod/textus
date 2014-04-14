//
//  AppController.h
//  Textus
//
//  Created by Jjgod Jiang on 3/16/09.
//

@import Cocoa;

@interface AppController : NSResponder

- (NSFont*)font;
- (NSColor*)foregroundColor;
- (NSColor*)backgroundColor;
- (IBAction)addBookmark:(id)sender;
- (IBAction)gotoBookmark:(id)sender;

@end
