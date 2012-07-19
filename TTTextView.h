//
//  JJTextView.h
//  Textus
//
//  Created by Jjgod Jiang on 3/16/09.
//

#import <Cocoa/Cocoa.h>
#import "TTProgressView.h"
#import <vector>

using namespace std;

typedef struct LineData {
    CTLineRef line;
    CGPoint   origin;
} JJLineData;

@class TTDocument;

@interface TTTextView : NSView {
    NSSize textInset;
    vector<JJLineData> textLines;
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
