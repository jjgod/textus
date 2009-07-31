//
//  MyDocument.h
//  Textus
//
//  Created by Jjgod Jiang on 2/16/09.
//  Copyright Jjgod Jiang 2009 . All rights reserved.
//


#import <Cocoa/Cocoa.h>

@interface JJTextView : NSView

@property (assign) NSSize textInset;
@property (retain) NSColor *backgroundColor;

- (void) setText: (NSString *) str;

@end

@interface TextDocument : NSDocument
{
    IBOutlet JJTextView *textView;
    NSStringEncoding GB18030Encoding;
    NSString *fileContents;
}

@end
