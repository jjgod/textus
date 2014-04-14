//
//  AppController.h
//  Textus
//
//  Created by Jjgod Jiang on 3/16/09.
//

#import <Cocoa/Cocoa.h>

@interface AppController : NSResponder {
  NSMutableDictionary* bookmarksDictionary;
}

- (NSFont*)font;
- (NSColor*)foregroundColor;
- (NSColor*)backgroundColor;
- (IBAction)addBookmark:(id)sender;
- (IBAction)gotoBookmark:(id)sender;

@end
