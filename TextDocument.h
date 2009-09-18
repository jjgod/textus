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
- (void) doPartialLayoutWithMaximumHeight: (CGFloat) height aroundLine: (NSUInteger) line;

@end

@interface TextDocument : NSDocument
{
    IBOutlet JJTextView *textView;
    NSStringEncoding GB18030Encoding;
    NSMutableAttributedString *fileContents;
    NSString *fileContentsInPlainText;
    NSUInteger lastReadLine, lastLayoutHeight;
}

@property (retain) NSMutableAttributedString *fileContents;
@property (retain) NSString *fileContentsInPlainText;
@property (assign) NSUInteger lastReadLine, lastLayoutHeight;

- (NSDictionary *) attributesForText;
- (void) saveMetaData;

@end
