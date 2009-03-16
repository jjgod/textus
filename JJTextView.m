//
//  JJTextView.m
//  Textus
//
//  Created by Jjgod Jiang on 3/16/09.
//  Copyright 2009 Jjgod Jiang. All rights reserved.
//

#import "JJTextView.h"

@implementation JJTextView

- (void) awakeFromNib
{
    [[NSApp delegate] addObserver:self
                       forKeyPath:@"backgroundColor"
                          options:0
                          context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    [self setBackgroundColor: [[NSApp delegate] backgroundColor]];
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

@end
