//
//  TTDocument.h
//  Textus
//
//  Created by Jjgod Jiang on 2/16/09.
//

#import <Cocoa/Cocoa.h>

@class TTTextView;

@interface TTDocument : NSDocument {
  IBOutlet TTTextView* textView;
}

@property(strong) NSMutableAttributedString* fileContents;
@property(strong) NSString* fileContentsInPlainText;
@property(assign) NSUInteger lastReadLocation;

- (NSDictionary*)attributesForText;
- (void)saveMetaData;
- (NSString*)firstLine:(NSString*)line;
- (void)outputTo:(NSMutableString*)output from:(NSString*)contents;

@end
