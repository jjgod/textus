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

@synthesize fileContents;

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
    [textView setDocument: self];
    if (fileContents)
        [textView invalidateLayout];
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
    NSString *contents;

    contents = [[NSString alloc] initWithData: data
                                     encoding: NSUTF8StringEncoding];
    if (! contents)
        contents = [[NSString alloc] initWithData: data
                                         encoding: GB18030Encoding];

    if (contents)
    {
        // Remove DOS line endings
        [self setFileContents: [contents stringByReplacingOccurrencesOfString: @"\r"
                                                                   withString: @""]];
        [contents release];
        readSuccess = YES;
    }

    if (outError != NULL)
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];

    return readSuccess;
}

@end
