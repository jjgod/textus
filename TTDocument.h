//
//  MyDocument.h
//  Textus
//
//  Created by Jjgod Jiang on 2/16/09.
//  Copyright Jjgod Jiang 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTTextView.h"

@interface TTDocument : NSDocument
{
    IBOutlet TTTextView *textView;
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
