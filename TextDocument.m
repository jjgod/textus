//
//  MyDocument.m
//  Textus
//
//  Created by Jjgod Jiang on 2/16/09.
//  Copyright Jjgod Jiang 2009 . All rights reserved.
//

#import "AppController.h"
#import "TextDocument.h"
#import "ExtendedAttributes.h"
#import <CommonCrypto/CommonDigest.h>

#define kLastReadLineKey @"org.jjgod.textus.lastReadLine"

@interface NSData (NSData_MD5Extensions)

- (NSString *) MD5Hash;

@end

@implementation NSData (NSData_MD5Extensions)

- (NSString *) MD5Hash
{
    CC_MD5_CTX theContext;
    int i;
    unsigned char digest[CC_MD5_DIGEST_LENGTH];

    CC_MD5_Init(&theContext);
    CC_MD5_Update(&theContext, [self bytes], [self length]);
    CC_MD5_Final(digest, &theContext);

    NSMutableString *hash = [NSMutableString stringWithCapacity: CC_MD5_DIGEST_LENGTH * 2];
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [hash appendFormat: @"%02x", digest[i]];

    return hash;
}

@end

@implementation TextDocument

@synthesize fileContents;
@synthesize lastReadLine;

- (id) init
{
    self = [super init];
    if (self) {
        GB18030Encoding = 
            CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        fileContents = nil;
        lastReadLine = 0;

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *keyPaths = [NSArray arrayWithObjects: @"backgroundColor", @"lineHeight", @"fontName", @"fontSize", nil];

        for (NSString *keyPath in keyPaths)
            [defaults addObserver: self
                       forKeyPath: keyPath
                          options: 0
                          context: nil];
    }
    return self;
}

- (void) dealloc
{
    [fileContents release];
    fileContents = nil;

    NSArray *keyPaths = [NSArray arrayWithObjects: @"backgroundColor", @"lineHeight", @"fontName", @"fontSize", nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    for (NSString *keyPath in keyPaths)
        [defaults removeObserver: self
                      forKeyPath: keyPath];

    [super dealloc];
}

- (void) saveMetaData
{
    [[self fileURL] setUnsignedInteger: lastReadLine forXattrKey: kLastReadLineKey];
}

- (NSString *) windowNibName
{
    return @"TextDocument";
}

- (void) windowControllerDidLoadNib: (NSWindowController *) aController
{
    [super windowControllerDidLoadNib: aController];

    [textView setDocument: self];
    if (fileContents)
    {
        [textView invalidateLayout];
        [textView scrollToLine: lastReadLine];
    }
}

- (NSData *) dataOfType: (NSString *) typeName
                  error: (NSError **) outError
{
    if (outError != NULL) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (NSDictionary *) attributesForText
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSFont fontWithName: [defaults stringForKey: @"fontName"]
                                                size: [defaults doubleForKey: @"fontSize"]],
                                (NSString *) kCTFontAttributeName,
                                nil];
    return attributes;
}

- (BOOL) readFromURL: (NSURL *) absoluteURL
              ofType: (NSString *) typeName
               error: (NSError **) outError
{
    BOOL readSuccess = NO;
    NSString *contents;
    NSData *data = [NSData dataWithContentsOfURL: absoluteURL];
    NSStringEncoding expectedEncoding;

    NSLog(@"hash: %@", [data MD5Hash]);

    expectedEncoding = [absoluteURL textEncoding];
    if (expectedEncoding)
        contents = [[NSString alloc] initWithData: data
                                         encoding: expectedEncoding];
    else
    {
        contents = [[NSString alloc] initWithData: data
                                         encoding: NSUTF8StringEncoding];
        if (! contents)
            contents = [[NSString alloc] initWithData: data
                                             encoding: GB18030Encoding];
    }

    if (contents)
    {
        if (fileContents)
            [fileContents release];
        // Remove DOS line endings
        fileContents = [[NSMutableAttributedString alloc] initWithString:
                                [contents stringByReplacingOccurrencesOfString: @"\r"
                                                                    withString: @""]
                                                              attributes: [self attributesForText]];
        [contents release];

        if ([[absoluteURL allXattrKeys] containsObject: kLastReadLineKey])
            lastReadLine = [absoluteURL unsignedIntegerFromXattrKey: kLastReadLineKey];

        NSLog(@"lastReadLine = %d", lastReadLine);
        readSuccess = YES;
    }

    return readSuccess;
}

- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *) context
{
    NSLog(@"keyPath = %@", keyPath);

    if ([keyPath isEqual: @"lineHeight"] ||
        [keyPath isEqual: @"fontName"] ||
        [keyPath isEqual: @"fontSize"])
    {
        if (fileContents)
        {
            [fileContents setAttributes: [self attributesForText]
                                  range: NSMakeRange(0, fileContents.length)];

            [textView invalidateLayout];
        }
    }
}

@end
