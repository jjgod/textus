//
//  JJTextView.h
//  Textus
//
//  Created by Jjgod Jiang on 3/16/09.
//

#import <Cocoa/Cocoa.h>
#import <vector>

typedef struct LineData {
    CTLineRef line;
    CGPoint   origin;
} JJLineData;

@class TTDocument;
@class TTProgressView;

@interface TTTextView : NSView {
    NSSize textInset;
    std::vector<JJLineData> textLines;
    TTDocument *__weak document;
    CGFloat lineHeight;
    CGFloat maxWidth;
    IBOutlet NSTextField *statusField;
    IBOutlet TTProgressView *progressView;
}

@property (assign) NSSize textInset;
@property (weak) TTDocument *document;

- (void) invalidateLayout;
- (void) scrollToLocation: (NSUInteger) location;

@end
