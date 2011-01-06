//
//  TTDocument.m
//  Textus
//
//  Created by Jjgod Jiang on 2/16/09.
//  Copyright Jjgod Jiang 2009 . All rights reserved.
//

#import "AppController.h"
#import "TTDocument.h"
#import "ExtendedAttributes.h"
#import "chardetect.h"

#define kLastReadLineKey    @"org.jjgod.textus.lastReadLine"

#define BUFSIZE	4096

/* Use universal charset detector to automatically determine which encoding
 * we should use to open the URL */
NSStringEncoding detectedEncodingForData(NSData *data)
{
    chardet_t chardetContext;
    char      charset[CHARDET_MAX_ENCODING_NAME];
    int       ret;

    CFStringEncoding cfenc;
    CFStringRef      charsetStr;

    chardet_create(&chardetContext);
    chardet_reset(chardetContext);
    chardet_handle_data(chardetContext, (const char *) [data bytes],
                        [data length] > BUFSIZE ? BUFSIZE : [data length]);
    chardet_data_end(chardetContext);

    ret = chardet_get_charset(chardetContext, charset, CHARDET_MAX_ENCODING_NAME);
    if (ret != CHARDET_RESULT_OK)
        return NSUTF8StringEncoding;

    NSLog(@"detected encoding: %s", charset);
    charsetStr = CFStringCreateWithCString(NULL, charset, kCFStringEncodingUTF8);
    cfenc = CFStringConvertIANACharSetNameToEncoding(charsetStr);
    CFRelease(charsetStr);

    chardet_destroy(chardetContext);

    return CFStringConvertEncodingToNSStringEncoding(cfenc);
}

@implementation TTDocument

@synthesize fileContents, fileContentsInPlainText;
@synthesize lastReadLine, lastLayoutHeight;

- (id) init
{
    self = [super init];
    if (self) {
        GB18030Encoding =
            CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        fileContents = nil;
        lastReadLine = lastLayoutHeight = 0;

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

- (void) close
{
    [self saveMetaData];
    [super close];
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
    NSURL *fileURL = [self fileURL];
    [fileURL setUnsignedInteger: lastReadLine forXattrKey: kLastReadLineKey];
}

- (NSString *) windowNibName
{
    return @"TTDocument";
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
    NSString *contents;
    NSData *data = [NSData dataWithContentsOfURL: absoluteURL];
    NSStringEncoding expectedEncoding;

    expectedEncoding = [absoluteURL textEncoding];
    if (expectedEncoding)
        contents = [[NSString alloc] initWithData: data
                                         encoding: expectedEncoding];
    else
        contents = [[NSString alloc] initWithData: data
                                         encoding: detectedEncodingForData(data)];
    if (contents)
    {
        if (fileContents)
            [fileContents release];

        [self setFileContentsInPlainText: contents];
        // Remove DOS line endings
        fileContents = [[NSMutableAttributedString alloc] initWithString:
                                [contents stringByReplacingOccurrencesOfString: @"\r"
                                                                    withString: @""]
                                                              attributes: [self attributesForText]];
        [contents release];

        NSArray *keys = [absoluteURL allXattrKeys];
        if ([keys containsObject: kLastReadLineKey])
            lastReadLine = [absoluteURL unsignedIntegerFromXattrKey: kLastReadLineKey];

        return YES;
    }

    return NO;
}

- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *) context
{
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
