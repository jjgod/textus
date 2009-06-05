//
//  JJTextView.m
//  Textus
//
//  Created by Jjgod Jiang on 3/16/09.
//  Copyright 2009 Jjgod Jiang. All rights reserved.
//

#import "JJTextView.h"

@implementation JJTextView

@synthesize textContainerInset;
@synthesize lineGap;
@synthesize backgroundColor;
@synthesize font;
@synthesize string;

- (void) awakeFromNib
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *keyPaths = [NSArray arrayWithObjects: @"backgroundColor", @"lineHeight", nil];

    for (NSString *keyPath in keyPaths)
        [defaults addObserver: self
                   forKeyPath: keyPath
                      options: 0
                      context: nil];

    self.textContainerInset = NSMakeSize(20, 20);
    self.lineGap = [defaults doubleForKey: @"lineHeight"];
}

- (void) dealloc
{
    [[NSUserDefaults standardUserDefaults] removeObserver: self
                                               forKeyPath: @"backgroundColor"];
    [[NSUserDefaults standardUserDefaults] removeObserver: self
                                               forKeyPath: @"lineHeight"];
    
    [super dealloc];
}

- (void) relayout
{
    NSLog(@"self string: %@", [self string]);
    if (string)
    {
        // Initialize a rectangular path.
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, NSRectToCGRect([self frame]));

        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString: string];

        // Create the framesetter with the attributed string.
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) attrString);
        [attrString release];

        if (frame)
            CFRelease(frame);

        // Create the frame and draw it into the graphics context
        frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);

        CFRelease(framesetter);
    }
}

- (void) drawRect: (NSRect) rect
{
    NSLog(@"rect: %@", NSStringFromRect(rect));

    [self relayout];

    // Initialize a graphics context and set the text matrix to a known value.
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CTFrameDraw(frame, context);
}

- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *) context
{
    NSLog(@"keyPath = %@", keyPath);

    if ([keyPath isEqual: @"backgroundColor"])
        self.backgroundColor = [[NSApp delegate] backgroundColor];

    else if ([keyPath isEqual: @"lineHeight"])
    {
        self.lineGap = [[NSUserDefaults standardUserDefaults] doubleForKey: @"lineHeight"];
        [self relayout];
    }
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
            [self scrollPageDown:self];
            break;
            
        case NSPageUpFunctionKey:
            [self scrollPageUp:self];
            break;
            
        case NSEndFunctionKey:
            y = NSMaxY([[[self enclosingScrollView] documentView] frame]) - 
                NSHeight([[[self enclosingScrollView] contentView] bounds]);
            [self scrollTo: y];
            break;
            
        case NSHomeFunctionKey:
            [self scrollTo:0.0];
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

- (void) changeFont: (id) sender
{
    NSFont *oldFont = [self font];
    NSFont *newFont = [sender convertFont: oldFont];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"changeFont = %@", newFont);
    
    [defaults setValue: [newFont fontName] forKey: @"fontName"];
    [defaults setValue: [NSNumber numberWithDouble: [newFont pointSize]] forKey: @"fontSize"];
}

@end
