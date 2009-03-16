//
//  JJTypesetter.h
//  Textus
//
//  Created by Jjgod Jiang on 3/16/09.
//  Copyright 2009 Jjgod Jiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JJTypesetter : NSATSTypesetter {
    CGFloat lineHeight;
}

@property (assign) CGFloat lineHeight;

@end
