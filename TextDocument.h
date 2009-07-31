//
//  MyDocument.h
//  Textus
//
//  Created by Jjgod Jiang on 2/16/09.
//  Copyright Jjgod Jiang 2009 . All rights reserved.
//


#import <Cocoa/Cocoa.h>

@class TextDocument;

@interface JJTextView : NSView

@property (assign) NSSize textInset;
@property (retain) NSColor *backgroundColor;
@property (assign) TextDocument *document;

- (void) invalidateLayout;

@end

@interface TextDocument : NSDocument
{
    IBOutlet JJTextView *textView;
    NSStringEncoding GB18030Encoding;
    NSMutableAttributedString *fileContents;
}

@property (retain) NSMutableAttributedString *fileContents;

@end
