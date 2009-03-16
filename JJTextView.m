//
//  JJTextView.m
//  Textus
//
//  Created by Jjgod Jiang on 3/16/09.
//  Copyright 2009 Jjgod Jiang. All rights reserved.
//

#import "JJTextView.h"
#import "JJTypesetter.h"

@implementation JJTextView

- (void) awakeFromNib
{
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"backgroundColor"
                                               options:0
                                               context:nil];

    [[NSUserDefaults standardUserDefaults] addObserver: self
                                            forKeyPath: @"lineHeight"
                                               options: 0
                                               context: nil];
    
    NSLayoutManager *lm = [self layoutManager];
    [self setTextContainerInset: NSMakeSize(20, 20)];
    
    JJTypesetter *ts = [[JJTypesetter alloc] init];
    [ts setLineHeight: [[NSUserDefaults standardUserDefaults] doubleForKey: @"fontSize"] +
                       [[NSUserDefaults standardUserDefaults] doubleForKey: @"lineHeight"]];
    [lm setTypesetter: ts];
    [ts release];
}

- (void) dealloc
{
    [[NSUserDefaults standardUserDefaults] removeObserver: self
                                               forKeyPath: @"backgroundColor"];
    [[NSUserDefaults standardUserDefaults] removeObserver: self
                                               forKeyPath: @"lineHeight"];
    
    [super dealloc];
}

- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *) context
{
    if ([keyPath isEqual: @"backgroundColor"])
        [self setBackgroundColor: [[NSApp delegate] backgroundColor]];
    
    else if ([keyPath isEqual: @"lineHeight"])
    {
        NSLayoutManager *lm = [self layoutManager];
        JJTypesetter *ts = (JJTypesetter *) [lm typesetter];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        CGFloat lineHeight = [defaults doubleForKey: @"fontSize"] + [defaults doubleForKey: @"lineHeight"];
        [ts setLineHeight: lineHeight];
        [self setNeedsDisplay: YES];
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
    
    NSLayoutManager *lm = [self layoutManager];
    JJTypesetter *ts = (JJTypesetter *) [lm typesetter];
    CGFloat lineHeight = [defaults doubleForKey: @"fontSize"] + [defaults doubleForKey: @"lineHeight"];
    [ts setLineHeight: lineHeight];
    [self setNeedsDisplay: YES];    
}

@end
