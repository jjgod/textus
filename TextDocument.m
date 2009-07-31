//
//  MyDocument.m
//  Textus
//
//  Created by Jjgod Jiang on 2/16/09.
//  Copyright Jjgod Jiang 2009 . All rights reserved.
//

#import "AppController.h"
#import "TextDocument.h"

@implementation TextDocument

- (id) init
{
    self = [super init];
    if (self) {
        GB18030Encoding = 
            CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        fileContents = nil;
    }
    return self;
}

- (void) dealloc
{
    [fileContents release];
    fileContents = nil;
    [super dealloc];
}

- (NSString *) windowNibName
{
    return @"TextDocument";
}

- (void) windowControllerDidLoadNib: (NSWindowController *) aController
{
    [super windowControllerDidLoadNib: aController];

    [textView setBackgroundColor: [(AppController *) [NSApp delegate] backgroundColor]];
    if (fileContents)
        [textView setText: fileContents];
}

- (NSData *) dataOfType: (NSString *) typeName
                  error: (NSError **) outError
{
    if (outError != NULL) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL) readFromData: (NSData *) data 
               ofType: (NSString *) typeName
                error: (NSError **) outError
{
    BOOL readSuccess = NO;

    fileContents = [[NSString alloc] initWithData: data 
                                         encoding: NSUTF8StringEncoding];
    if (! fileContents)
        fileContents = [[NSString alloc] initWithData: data 
                                             encoding: GB18030Encoding];

    if (fileContents)
        readSuccess = YES;

    if (outError != NULL)
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];

    return readSuccess;
}

@end
