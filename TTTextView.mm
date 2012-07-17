//
//  JJTextView.m
//  Textus
//
//  Created by Jjgod Jiang on 3/16/09.
//

#import "TTTextView.h"
#import "TTDocument.h"
#include <sys/time.h>

#define kMaxLinesPerFrame     256
#define MAX_LINES(total)      (total > kMaxLinesPerFrame ? kMaxLinesPerFrame : total)
#define JJ_CUSTOM_FRAMESETTER 1
// #define TT_LAYOUT_TIMING      1

@implementation TTTextView

@synthesize textInset;
@synthesize document;

- (id) initWithFrame: (NSRect) frameRect
{
    if ((self = [super initWithFrame: frameRect]))
    {
        textInset = NSMakeSize(50, 50);
        textLines.clear();
    }
    return self;
}

- (void) removeAllLines
{
    NSUInteger i, count = textLines.size();

    for (i = 0; i < count; i++) {
        if (textLines[i].line)
            CFRelease(textLines[i].line);
    }

    textLines.clear();
}

- (void) dealloc
{
    [self removeAllLines];
    [super dealloc];
}

- (void) invalidateLayout
{
    NSAttributedString *text = [document fileContents];

    if (! text)
        return;

    NSSize contentSize = [[self enclosingScrollView] contentSize];
    CTFontRef font = (CTFontRef) [text attribute: (NSString *) kCTFontAttributeName
                                         atIndex: 0
                                  effectiveRange: NULL];
    lineHeight = CTFontGetAscent(font) + CTFontGetDescent(font) + CTFontGetLeading(font);
    lineHeight *= [[NSUserDefaults standardUserDefaults] doubleForKey: @"lineHeight"];
    CGFloat lineAscent = CTFontGetAscent(font);

    CGFloat scrollerWidth = [NSScroller isCompatibleWithOverlayScrollers] ? 0 : [NSScroller scrollerWidth];
    CGRect frameRect = CGRectMake(textInset.width, textInset.height,
                                  contentSize.width - 2 * textInset.width - scrollerWidth,
                                  contentSize.height - textInset.height);

    JJLineData lineData = { NULL, CGPointMake(0, 0) };

    [self removeAllLines];

#ifdef TT_LAYOUT_TIMING
    struct timeval tv1, tv2;
    gettimeofday(&tv1, 0);
#endif

#ifdef JJ_CUSTOM_FRAMESETTER
    CGFloat fontSize = CTFontGetSize(font);
    CFStringRef str = (CFStringRef) document.fileContentsInPlainText;
    CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((CFAttributedStringRef) text);
    CFIndex start, length = 0;
    maxWidth = floor(frameRect.size.width / fontSize) * fontSize;
    lineData.origin = frameRect.origin;

    for (start = 0; start < text.length; start += length) {
        length = CTTypesetterSuggestLineBreak(typesetter, start, frameRect.size.width);
        if (length == 1 && CFStringGetCharacterAtIndex(str, start) == '\n')
            continue;
        lineData.line = CTTypesetterCreateLine(typesetter, CFRangeMake(start, length));
        CGFloat ascent, descent, leading;
        double width = CTLineGetTypographicBounds(lineData.line, &ascent, &descent, &leading);

        CFIndex secondCharInNextLineIndex = start + length + 1;
        if (width <= maxWidth - fontSize) {
            if (secondCharInNextLineIndex < text.length) {
                UniChar ch = CFStringGetCharacterAtIndex(str, secondCharInNextLineIndex);
                // TODO: handle ⋯⋯” at the beginning of next line
                if (ch == 0xFF0C /* ， */ || ch == 0x3002 /* 。 */ ||
                    ch == 0x3001 /* 、 */ || ch == 0xFF01 /* ！ */ ||
                    ch == 0xFF1A /* ： */ || ch == 0xFF1B /* ； */ ||
                    ch == 0x201D /* ” */  || ch == 0x201C /* “ */ ||
                    ch == 0x300C /* 「 */ || ch == 0xFF1F /* ？ */) {
                    CFRelease(lineData.line);
                    length += (ch == 0x201C || ch == 0x300C) ? 1 : 2;

                    // For situations like "，”" or "。」", we need to extend the length one more char
                    // to include the quote
                    if (secondCharInNextLineIndex + 1 < text.length) {
                        ch = CFStringGetCharacterAtIndex(str, secondCharInNextLineIndex + 1);
                        if (ch == 0x201D /* ” */ || ch == 0x300D /* 」 */ ||
                            ch == 0xFF0C /* ， */ || ch == 0x3002 /* 。 */)
                        length += 1;
                    }
                    lineData.line = CTTypesetterCreateLine(typesetter, CFRangeMake(start, length));
                    // NSLog(@"%@", [document.fileContentsInPlainText substringWithRange: NSMakeRange(start, length)]);
                }
            }
            if (start + length < text.length && CFStringGetCharacterAtIndex(str, start + length) == '\n')
                length += 1;
        } else {
            // Otherwise we can't do optical punctuation or the beginning of a paragraph, do justified line instead
            if (width / maxWidth > 0.85 && CFStringGetCharacterAtIndex(str, start) != 0x3000) {
                CTLineRef justifiedLine = CTLineCreateJustifiedLine(lineData.line, 1.0, maxWidth);
                CFRelease(lineData.line);
                lineData.line = justifiedLine;
            }
        }
        lineData.origin.y = frameRect.origin.y + lineAscent;
        textLines.push_back(lineData);
        frameRect.origin.y += lineHeight;

        // Add extra line here as paragraph spacing
        if (CFStringGetCharacterAtIndex(str, start + length - 1) == '\n') {
            // NSLog(@"%@", [document.fileContentsInPlainText substringWithRange: NSMakeRange(start, length)]);
            frameRect.origin.y += lineHeight;
        }
    }

    CFRelease(typesetter);
#else
    // Create the framesetter with the attributed string.
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) text);
    CFRange range, frameRange;

    for (range = frameRange = CFRangeMake(0, 0);
         range.location < text.length;
         range.location += frameRange.length)
    {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, frameRect);

        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, range, path, NULL);
        frameRange = CTFrameGetVisibleStringRange(frame);
        CFArrayRef lines = CTFrameGetLines(frame);
        CFIndex i, total = CFArrayGetCount(lines);
        CGFloat y = frameRect.origin.y;
        for (i = 0; i < total; i++)
        {
            lineData.line = (CTLineRef) CFRetain(CFArrayGetValueAtIndex(lines, i));
            lineData.origin = CGPointMake(frameRect.origin.x, y + lineAscent);
            y += lineHeight;
            textLines.push_back(lineData);
        }
        frameRect.origin.y = y;
        frameRect.size.height = contentSize.height;
        CFRelease(path);
        CFRelease(frame);
    }

    CFRelease(framesetter);
#endif

#ifdef TT_LAYOUT_TIMING
    gettimeofday(&tv2, 0);
    int msec = (tv2.tv_sec - tv1.tv_sec) * 1000 + (tv2.tv_usec - tv1.tv_usec) / 1000;
    NSLog(@"time used = %d msecs", msec);
#endif

    NSRect newFrame = [self frame];
    newFrame.size.height = lineData.origin.y + textInset.height;

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

    // NSRectFill(NSMakeRect(textInset.width + maxWidth, rect.origin.y, 1.5, rect.size.height));

    from = [self lineBefore: rect.origin.y];
    NSUInteger firstLineInView = [self lineBefore: [[self enclosingScrollView] documentVisibleRect].origin.y] + 1;
    if (firstLineInView < total)
    {
        CFRange range = CTLineGetStringRange(textLines[firstLineInView].line);
        document.lastReadLocation = range.location;
    }

    for (i = from; i < total && lineData.origin.y <= bottom; i++)
    {
        lineData = textLines[i];
        CGContextSetTextPosition(context, lineData.origin.x, lineData.origin.y);
        CTLineDraw(lineData.line, context);
    }

    long percentage = roundtol(i * 100 / total);
    if (percentage) {
        statusField.integerValue = percentage;
        statusField.stringValue = [NSString stringWithFormat: @"%ld%%", percentage];
    }
    else
        statusField.stringValue = @"";
    [progressView setNeedsDisplay: YES];
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
    CGFloat pageHeight = [(NSScrollView *) [self superview] documentVisibleRect].size.height - lineHeight;

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

- (void) scrollToLocation: (NSUInteger) location
{
    for (NSUInteger i = 0; i < textLines.size(); i++)
    {
        CFRange range = CTLineGetStringRange(textLines[i].line);
        if (range.location >= location)
        {
            CGFloat y = 0.0;
            if (i > 0) {
                CGFloat height = textLines[i].origin.y - textLines[i - 1].origin.y;
                CTFontRef font = (CTFontRef) [[document fileContents] attribute: (NSString *) kCTFontAttributeName
                                                                        atIndex: 0
                                                                 effectiveRange: NULL];
                CGFloat padding = (height - CTFontGetAscent(font) - CTFontGetDescent(font)) / 2;
                y = textLines[i].origin.y - CTFontGetAscent(font) - padding;
            }
            [self scrollTo: y];
            return;
        }
    }
    [self scrollTo: 0];
}

@end
