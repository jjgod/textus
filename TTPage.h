//
//  TTPage.h
//  Textus
//
//  Created by Jiang Jiang on 4/20/10.
//  Copyright 2010 Jjgod Jiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TTPage : NSObject {
    CGRect frame;
    CFRange textRange;
    CTFramesetterRef framesetter;
    CFArrayRef lines;
    CGFloat lineHeight, lineAscent;
    BOOL drawn;
}

- (id) initWithContents: (CFAttributedStringRef) contents atRange: (CFRange) initialRange inFrame: (CGRect) theFrame;

- (CGFloat) height;

@property (readonly) CFRange textRange;
@property (readonly) CFArrayRef lines;
@property (readonly) CGFloat lineHeight, lineAscent;
@property (assign) BOOL drawn;

@end
