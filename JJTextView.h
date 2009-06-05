//
//  JJTextView.h
//  Textus
//
//  Created by Jjgod Jiang on 3/16/09.
//  Copyright 2009 Jjgod Jiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JJTextView : NSView {
    NSSize textContainerInset;
    CGFloat lineGap;
    NSColor *backgroundColor;
    NSFont *font;
    NSString *string;
    CTFrameRef frame;
}

@property (assign) NSSize textContainerInset;
@property (assign) CGFloat lineGap;
@property (retain) NSColor *backgroundColor;
@property (retain) NSFont *font;
@property (copy) NSString *string;

- (void) relayout;

@end
