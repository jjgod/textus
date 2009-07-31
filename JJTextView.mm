//
//  JJTextView.m
//  Textus
//
//  Created by Jjgod Jiang on 3/16/09.
//  Copyright 2009 Jjgod Jiang. All rights reserved.
//

#import "JJTextView.h"
#import <time.h>

#define kMaxLinesPerFrame 256

#define MAX_LINES(total)    (total > kMaxLinesPerFrame ? kMaxLinesPerFrame : total)

@implementation JJTextView

@synthesize textInset;
@synthesize document;

- (id) initWithFrame: (NSRect) frameRect
{
    if ((self = [super initWithFrame: frameRect]))
    {
        textInset = NSMakeSize(20, 20);
        textLines.clear();
    }
    return self;
}

- (void) removeAllLines
{
    NSUInteger i, count = textLines.size();

    NSLog(@"total lines: %u", count);

    for (i = 0; i < count; i++)
        CFRelease(textLines[i].line);

    textLines.clear();
}

- (void) invalidateLayout
{
    NSMutableAttributedString *text = [document fileContents];
    clock_t startTime = clock(), duration;

    if (! text)
        return;

    NSRect rect = [[self enclosingScrollView] documentVisibleRect];
    NSLog(@"rect to draw: %@", NSStringFromRect(rect));
    NSRect newFrame = rect;

    // Create the framesetter with the attributed string.
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) text);

    CFRange fullRange = CFRangeMake(0, text.length);
    CGRect frameRect = CGRectMake(textInset.width, textInset.height,
                                  rect.size.width - 2 * textInset.width,
                                  rect.size.height - textInset.height);

    CFRange range, frameRange;
    CGPoint origins[kMaxLinesPerFrame];
    CGFloat ascent, descent, leading;
    ascent = descent = leading = 0;
    JJLineData lineData = { NULL, CGPointMake(0, 0) };

    [self removeAllLines];
    for (range = frameRange = CFRangeMake(0, 0);
         range.location < fullRange.length;
         range.location += frameRange.length)
    {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, frameRect);

        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, range, path, NULL);
        frameRange = CTFrameGetVisibleStringRange(frame);

        CFArrayRef lines = CTFrameGetLines(frame);
        CFIndex i, total = CFArrayGetCount(lines);
        CGFloat y;

        CTFrameGetLineOrigins(frame, CFRangeMake(0, MAX_LINES(total)), origins);

        for (i = 0; i < total; i++)
        {
            lineData.line = (CTLineRef) CFRetain(CFArrayGetValueAtIndex(lines, i));
            y = frameRect.origin.y + frameRect.size.height - origins[i].y;
            // NSLog(@"y = %g\n", y);
            lineData.origin = CGPointMake(frameRect.origin.x + origins[i].x,
                                          y);
            textLines.push_back(lineData);
        }

#if 0
        NSLog(@"frameRange: %ld, %ld, %@",
              frameRange.location, frameRange.length,
              NSStringFromRect(NSRectFromCGRect(frameRect)));
#endif
        // range.location += frameRange.length;
        if (lineData.line)
            CTLineGetTypographicBounds(lineData.line, &ascent, &descent, &leading);

        frameRect.origin.y = lineData.origin.y + descent + leading;
        frameRect.size.height = rect.size.height;

        CFRelease(path);
        CFRelease(frame);
    }

    CFRelease(framesetter);

    duration = clock() - startTime;
    NSLog(@"layout time = %g secs", (double) duration / (double) CLOCKS_PER_SEC);
    newFrame.size.height = frameRect.origin.y + textInset.height;
    [self setFrame: newFrame];
    [self setNeedsDisplay: YES];
}

- (BOOL) isFlipped
{
    return YES;
}

// Do a binary search to find the line requested
- (NSUInteger) lineBefore: (CGFloat) y
{
    NSUInteger i;

    for (i = 0; i < textLines.size(); i++)
        if (textLines[i].origin.y > y)
            return i == 0 ? 0 : i - 1;

    return i;
}

- (void) drawRect: (NSRect) rect
{
    // Initialize a graphics context and set the text matrix to a known value.
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1, -1));

    NSUInteger i, from, total = textLines.size();
    JJLineData lineData = { NULL, CGPointZero };
    CGFloat bottom = rect.origin.y + rect.size.height;

    from = [self lineBefore: rect.origin.y];
    for (i = from; i < total && lineData.origin.y <= bottom; i++)
    {
        lineData = textLines[i];

        CGContextSetTextPosition(context, lineData.origin.x, lineData.origin.y);
        CTLineDraw(lineData.line, context);
    }

    // NSLog(@"drawLines from: %u to %u", from, i);
}

- (void) scrollTo: (float) y
{
    [self scrollPoint: NSMakePoint(0.0, y)];
}

- (void) scrollBy: (float) value
{
    CGFloat y;
    NSRect rect;

    rect = [[self enclosingScrollView] documentVisibleRect];
    y = rect.origin.y;
    y += value;

    [self scrollTo: y];
}

- (BOOL) processKey: (int) ch
{
    float y;
    CGFloat pageHeight = [(NSScrollView *) [self superview] documentVisibleRect].size.height;

    switch (ch)
    {
        case NSDownArrowFunctionKey:
            [self scrollBy: 100.0];
            break;
            
        case NSUpArrowFunctionKey:
            [self scrollBy: -100.0];
            break;
            
        case ' ':
        case NSPageDownFunctionKey:
            [self scrollBy: pageHeight];
            break;
            
        case NSPageUpFunctionKey:
            [self scrollBy: -pageHeight];
            break;
            
        case NSEndFunctionKey:
            y = NSMaxY([[[self enclosingScrollView] documentView] frame]) - 
            NSHeight([[[self enclosingScrollView] contentView] bounds]);
            [self scrollTo: y];
            break;

        case NSHomeFunctionKey:
            [self scrollTo: 0];
            break;

        default:
            return NO;
    }

    return YES;
}

- (void) keyDown: (NSEvent *) event 
{
    int characterIndex;
    int charactersInEvent;

    charactersInEvent = [[event characters] length];
    for (characterIndex = 0; characterIndex < charactersInEvent;  
         characterIndex++) {
        int ch = [[event characters] characterAtIndex:characterIndex];
        
        if ([self processKey: ch] == NO)
            [self interpretKeyEvents:[NSArray arrayWithObject:event]];
    }
}

- (BOOL) acceptsFirstResponder
{
    return YES;
}

- (void) viewDidEndLiveResize
{
    [self invalidateLayout];
}

@end
