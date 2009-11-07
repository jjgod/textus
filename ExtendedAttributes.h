//
//  ExtendedAttributes.h
//  Textus
//
//  Created by Jiang Jiang on 9/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSURL (ExtendedAttributes)

- (NSArray *) allXattrKeys;
- (NSUInteger) unsignedIntegerFromXattrKey: (NSString *) key;
- (void) setUnsignedInteger: (NSUInteger) num forXattrKey: (NSString *) key;
- (NSStringEncoding) textEncoding;

- (NSString *) stringFromXattrKey: (NSString *) key;
- (void) setString: (NSString *) str forXattrKey: (NSString *) key;

@end
