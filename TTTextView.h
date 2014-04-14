//
//  TTTextView.h
//  Textus
//
//  Created by Jjgod Jiang on 3/16/09.
//

#import <Cocoa/Cocoa.h>

@class TTDocument;

@interface TTTextView : NSView {
  IBOutlet NSTextField* statusField;
  IBOutlet NSView* progressView;
}

@property(assign) NSSize textInset;
@property(weak) TTDocument* document;

- (void)invalidateLayout;
- (void)scrollToLocation:(NSUInteger)location;

@end
