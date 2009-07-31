//
//  JJTextView.h
//  Textus
//
//  Created by Jjgod Jiang on 3/16/09.
//  Copyright 2009 Jjgod Jiang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JJTextView : NSView {
    NSSize textInset;
    NSColor *backgroundColor;
    NSString *string;
    NSMutableArray *textFrames;
}

@property (assign) NSSize textInset;
@property (retain) NSColor *backgroundColor;

- (void) setString: (NSString *) string;
- (void) invalidateLayout;

@end
