//
//  TTTextView.h
//  Textus
//
//  Created by Jjgod Jiang on 3/16/09.
//

#import <Cocoa/Cocoa.h>
#import <vector>

typedef struct LineData {
  CTLineRef line;
  CGPoint origin;
} JJLineData;

@class TTDocument;

@interface TTTextView : NSView {
  NSSize textInset;
  std::vector<JJLineData> textLines;
  TTDocument* __weak document;
  CGFloat _lineHeight;
  CGFloat _fontAscent;
  CGFloat _fontDescent;
  CGFloat maxWidth;
  IBOutlet NSTextField* statusField;
  IBOutlet NSView* progressView;
}

@property(assign) NSSize textInset;
@property(weak) TTDocument* document;

- (void)invalidateLayout;
- (void)scrollToLocation:(NSUInteger)location;

@end
