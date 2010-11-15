//
//  TTPage.m
//  Textus
//
//  Created by Jiang Jiang on 4/20/10.
//  Copyright 2010 Jjgod Jiang. All rights reserved.
//

#import "TTPage.h"

@implementation TTPage

@synthesize textRange, lines, lineHeight, lineAscent, drawn;

- (id) initWithContents: (CFAttributedStringRef) contents
                atRange: (CFRange) initialRange
                inFrame: (CGRect) theFrame
{
    if (self = [super init])
    {
        NSLog(@"Creating page with range: %d, %d (%gx%g)", initialRange.location, initialRange.length,
              theFrame.size.width, theFrame.size.height);
        CFAttributedStringRef substring = CFAttributedStringCreateWithSubstring(0, contents, initialRange);
        CTFontRef font = CFAttributedStringGetAttribute(contents, 0, kCTFontAttributeName, NULL);
        lineHeight = CTFontGetAscent(font) + CTFontGetDescent(font) + CTFontGetLeading(font);
        lineHeight *= [[NSUserDefaults standardUserDefaults] doubleForKey: @"lineHeight"];
        lineHeight = ceil(lineHeight);
        NSLog(@"lineHeight = %g", lineHeight);

        lineAscent = CTFontGetAscent(font);
        drawn = NO;

        framesetter = CTFramesetterCreateWithAttributedString(substring);
        CFRelease(substring);

        frame = theFrame;
        if (framesetter)
        {
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathAddRect(path, NULL, frame);
            CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
            lines = CFRetain(CTFrameGetLines(textFrame));

            CFRelease(path);
            textRange = CTFrameGetVisibleStringRange(textFrame);
            // NSLog(@"textRange: %d, %d", textRange.location, textRange.length);
            textRange.location = initialRange.location;
            CFRelease(textFrame);
            CFRelease(framesetter);
        }
    }
    return self;
}

- (CGFloat) height
{
    return lineHeight * CFArrayGetCount(lines);
}

- (void) dealloc
{
    if (lines)
        CFRelease(lines);
    [super dealloc];
}

@end
