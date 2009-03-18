//
//  JJTypesetter.h
//  Textus
//
//  Created by Jjgod Jiang on 3/18/09.
//  Copyright 2009 Jjgod Jiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JJTypesetter : NSATSTypesetter {
    CGFloat lineGap;
}

@property (assign) CGFloat lineGap;

@end
