//
//  JJTypesetter.m
//  Textus
//
//  Created by Jjgod Jiang on 3/16/09.
//  Copyright 2009 Jjgod Jiang. All rights reserved.
//

#import "JJTypesetter.h"

@implementation JJTypesetter

@synthesize lineHeight;

- (void) willSetLineFragmentRect: (NSRectPointer) lineRect 
                   forGlyphRange: (NSRange) glyphRange 
                        usedRect: (NSRectPointer) usedRect 
                  baselineOffset: (CGFloat *) baselineOffset
{
    lineRect->size.height = lineHeight;
    usedRect->size.height = lineHeight;
    // *baselineOffset = _baselineOffset;
}

@end
