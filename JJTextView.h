//
//  JJTextView.h
//  Textus
//
//  Created by Jjgod Jiang on 3/16/09.
//  Copyright 2009 Jjgod Jiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <vector>

using namespace std;

typedef struct LineData {
    CTLineRef line;
    CGPoint   origin;
} JJLineData;

@interface TextDocument : NSDocument

@property (retain) NSString *fileContents;

@end

@interface JJTextView : NSView {
    NSSize textInset;
    NSColor *backgroundColor;
    vector<JJLineData> textLines;
    TextDocument *document;
}

@property (assign) NSSize textInset;
@property (retain) NSColor *backgroundColor;
@property (assign) TextDocument *document;

- (void) invalidateLayout;

@end
