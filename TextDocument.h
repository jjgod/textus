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
- (void) scrollToLine: (NSUInteger) line;

@end

@interface TextDocument : NSDocument
{
    IBOutlet JJTextView *textView;
    NSStringEncoding GB18030Encoding;
    NSMutableAttributedString *fileContents;
    NSUInteger lastReadLine;
}

@property (retain) NSMutableAttributedString *fileContents;
@property (assign) NSUInteger lastReadLine;

- (void) saveMetaData;

@end
