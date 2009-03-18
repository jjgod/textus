//
//  JJTypesetter.m
//  Textus
//
//  Created by Jjgod Jiang on 3/18/09.
//  Copyright 2009 Jjgod Jiang. All rights reserved.
//

#import "JJTypesetter.h"

@implementation JJTypesetter

@synthesize lineGap;

- (void) willSetLineFragmentRect: (NSRectPointer) lineRect 
                   forGlyphRange: (NSRange) glyphRange 
                        usedRect: (NSRectPointer) usedRect 
                  baselineOffset: (CGFloat *) baselineOffset
{
    CGFloat lineHeight = lineRect->size.height + lineGap;

    lineRect->size.height = lineHeight;
    usedRect->size.height = lineHeight;
}

@end
