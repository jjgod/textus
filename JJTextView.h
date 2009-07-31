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

@interface JJTextView : NSView {
    NSSize textInset;
    NSColor *backgroundColor;
    NSString *text;
    vector<JJLineData> textLines;
}

@property (assign) NSSize textInset;
@property (retain) NSColor *backgroundColor;

- (void) setText: (NSString *) str;

- (void) invalidateLayout;

@end
