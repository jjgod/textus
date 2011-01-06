//
//  TTDocument.h
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
    NSMutableAttributedString *fileContents;
    NSString *fileContentsInPlainText;
    NSUInteger lastReadLocation;
}

@property (retain) NSMutableAttributedString *fileContents;
@property (retain) NSString *fileContentsInPlainText;
@property (assign) NSUInteger lastReadLocation;

- (NSDictionary *) attributesForText;
- (void) saveMetaData;

@end
