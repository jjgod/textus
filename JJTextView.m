//
//  JJTextView.m
//  Textus
//
//  Created by Jjgod Jiang on 3/16/09.
//  Copyright 2009 Jjgod Jiang. All rights reserved.
//

#import "JJTextView.h"

void CTFrameDrawLines(CTFrameRef frame, CGContextRef context)
{
    CFArrayRef lines = CTFrameGetLines(frame);
    CFIndex i, total = CFArrayGetCount(lines);
    CGPoint origins[255];
    CGRect rect = CGPathGetBoundingBox(CTFrameGetPath(frame));
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);

    // NSLog(@"bounding rect: %@", NSStringFromRect(NSRectFromCGRect(rect)));
    for (i = 0; i < total; i++)
    {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        // NSLog(@"origins[%d].y = %g", i, rect.size.height - origins[i].y);
        CGContextSetTextPosition(context,
                                 rect.origin.x + origins[i].x,
                                 rect.origin.y + rect.size.height - origins[i].y);
        CTLineDraw(line, context);
    }
}

@implementation JJTextView

@synthesize textInset;
@synthesize backgroundColor;

- (id) initWithFrame: (NSRect) frameRect
{
    if ((self = [super initWithFrame: frameRect]))
    {
        textInset = NSMakeSize(20, 20);
        textFrames = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) awakeFromNib
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *keyPaths = [NSArray arrayWithObjects: @"backgroundColor", @"lineHeight", @"fontName", @"fontSize", nil];

    for (NSString *keyPath in keyPaths)
        [defaults addObserver: self
                   forKeyPath: keyPath
                      options: 0
                      context: nil];
}

- (void) dealloc
{
    [[NSUserDefaults standardUserDefaults] removeObserver: self
                                               forKeyPath: @"backgroundColor"];
    [[NSUserDefaults standardUserDefaults] removeObserver: self
                                               forKeyPath: @"lineHeight"];
    [string release];
    string = nil;
    
    [textFrames release];
    textFrames = nil;

    [super dealloc];
}

- (void) setString: (NSString *) str
{
    string = [str retain];
    [self invalidateLayout];
}

- (void) invalidateLayout
{
    if (! string)
        return;

    NSRect rect = [[self enclosingScrollView] documentVisibleRect];
    NSLog(@"rect to draw: %@", NSStringFromRect(rect));
    NSRect newFrame = rect;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat lineHeight = [defaults doubleForKey: @"lineHeight"];

    CTParagraphStyleSetting settings[] = {
        { kCTParagraphStyleSpecifierLineHeightMultiple, sizeof(CGFloat), &lineHeight },
    };
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings) / sizeof(settings[0]));
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString: string];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys: 
                                [NSFont fontWithName: [defaults stringForKey: @"fontName"]
                                                size: [defaults doubleForKey: @"fontSize"]],
                                (NSString *) kCTFontAttributeName,
                                paragraphStyle, (NSString *) kCTParagraphStyleAttributeName,
                                nil];
    CFRelease(paragraphStyle);

    [attrString setAttributes: attributes
                        range: NSMakeRange(0, string.length)];

    // Create the framesetter with the attributed string.
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) attrString);
    [attrString release];

    CFRange fullRange = CFRangeMake(0, string.length);
    CGRect frameRect = CGRectMake(textInset.width, textInset.height,
                                  rect.size.width - 2 * textInset.width,
                                  rect.size.height - textInset.height);

    [textFrames removeAllObjects];
    CFRange range, frameRange;
    for (range = frameRange = CFRangeMake(0, 0);
         range.location < fullRange.length;
         range.location += frameRange.length)
    {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, frameRect);

        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, range, path, NULL);
        frameRange = CTFrameGetVisibleStringRange(frame);
#if 0
        NSLog(@"frameRange: %ld, %ld, %@",
              frameRange.location, frameRange.length,
              NSStringFromRect(NSRectFromCGRect(frameRect)));
#endif
        // range.location += frameRange.length;
        frameRect.origin.y += frameRect.size.height;
        frameRect.size.height = rect.size.height;

        [textFrames addObject: (id) frame];

        CFRelease(path);
        CFRelease(frame);
    }

    CFRelease(framesetter);

    newFrame.size.height = frameRect.origin.y;
    [self setFrame: newFrame];
    [self setNeedsDisplay: YES];
}

- (BOOL) isFlipped
{
    return YES;
}

- (void) drawRect: (NSRect) rect
{
    // NSLog(@"rect: %@", NSStringFromRect(rect));

    // Initialize a graphics context and set the text matrix to a known value.
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1, -1));

    CTFrameRef frame = (CTFrameRef) [textFrames objectAtIndex: 1];
    if (! frame)
        frame = (CTFrameRef) [textFrames objectAtIndex: 0];
    if (! frame)
        return;

    CGRect bounds = CGPathGetBoundingBox(CTFrameGetPath(frame));
    NSUInteger i, start = (rect.origin.y - textInset.height) / bounds.size.height;

    for (i = start; i < start + 2 && i < [textFrames count]; i++)
    {
        frame = (CTFrameRef) [textFrames objectAtIndex: i];

#if 0
        NSLog(@"drawing frame: %lu, rect: %@", i, NSStringFromRect(NSRectFromCGRect(bounds)));
        CGRect bounds = CGPathGetBoundingBox(CTFrameGetPath(frame));

        CGContextSetRGBFillColor(context, 0.1, 0.7, 0.7, 1.0);
        NSRectFill(NSRectFromCGRect(bounds));

        [[NSColor redColor] set];
        NSRectFill(NSMakeRect(200, bounds.origin.y, 50, 1.5));

        [[NSColor blackColor] set];
        NSRectFill(NSMakeRect(0, bounds.origin.y + bounds.size.height, 50, 1.5));
#endif
        CTFrameDrawLines((CTFrameRef) frame, context);
    }
}

- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *) context
{
    NSLog(@"keyPath = %@", keyPath);

    if ([keyPath isEqual: @"backgroundColor"])
        self.backgroundColor = [[NSApp delegate] backgroundColor];

    else if ([keyPath isEqual: @"lineHeight"] ||
             [keyPath isEqual: @"fontName"] ||
             [keyPath isEqual: @"fontSize"])
        [self invalidateLayout];
}

- (void) scrollTo: (float) y
{
    [self scrollPoint: NSMakePoint(0.0, y)];
}

- (void) scrollBy: (float) value
{
    float y;
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

@end
