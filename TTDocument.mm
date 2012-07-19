//
//  TTDocument.m
//  Textus
//
//  Created by Jjgod Jiang on 2/16/09.
//

#import "AppController.h"
#import "TTDocument.h"
#import "ExtendedAttributes.h"
#import "chardetect.h"
#import "TTTextView.h"

extern "C" {
#import "libsoldout/markdown.h"
}

#define kLastReadLocationKey    @"org.jjgod.textus.lastReadLocation"
#define BUFSIZE                 4096


struct tt_format_data {
    NSMutableAttributedString *str;
    CTFontRef normalFont;
    CTFontRef h1Font;
    CTFontRef h2Font;
    CTFontRef h3Font;
    CTFontRef h4Font;
};

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
    chardet_destroy(chardetContext);
    if (ret != CHARDET_RESULT_OK)
        return NSUTF8StringEncoding;

    charsetStr = CFStringCreateWithCString(NULL, charset, kCFStringEncodingUTF8);
    cfenc = CFStringConvertIANACharSetNameToEncoding(charsetStr);
    CFRelease(charsetStr);

    return CFStringConvertEncodingToNSStringEncoding(cfenc);
}

@implementation TTDocument

@synthesize fileContents, fileContentsInPlainText;
@synthesize lastReadLocation;

- (id) init
{
    self = [super init];
    if (self) {
        fileContents = nil;
        lastReadLocation = 0;

        linePrefixCharset = [NSCharacterSet characterSetWithCharactersInString: @"　 "];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *keyPaths = @[@"backgroundColor", @"lineHeight", @"fontName", @"fontSize"];

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

    NSArray *keyPaths = @[@"backgroundColor", @"lineHeight", @"fontName", @"fontSize"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    for (NSString *keyPath in keyPaths)
        [defaults removeObserver: self
                      forKeyPath: keyPath];

}

- (void) saveMetaData
{
    NSURL *fileURL = [self fileURL];
    [fileURL setUnsignedInteger: lastReadLocation forXattrKey: kLastReadLocationKey];
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
        [textView scrollToLocation: lastReadLocation];
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
    NSDictionary *attributes = @{(NSString *) kCTFontAttributeName: [NSFont fontWithName: [defaults stringForKey: @"fontName"]
                                                size: [defaults doubleForKey: @"fontSize"]]};
    return attributes;
}

#define outputLine(output, line)           [output appendFormat: @"%@\n", line]
#define outputParagraph(output, paragraph) do { \
[output appendFormat: @"%@\n\n", paragraph]; \
paragraph = nil; \
} while (0)

- (NSString *) firstLine: (NSString *) line
{
    line = [line stringByTrimmingCharactersInSet: linePrefixCharset];

    // Align first line with “「 optically
    NSString *prefix = @"　　";
    if (line.length > 0) {
        UniChar ch = [line characterAtIndex: 0];
        if (ch == 0x201C /* “ */ || ch == 0x300C /* 「 */)
            prefix = @"　";
    }

    return [prefix stringByAppendingString: line];
}

- (void) outputTo: (NSMutableString *) output from: (NSString *) contents
{
    BOOL inParagraph = NO;
    NSUInteger length = [contents length];
    NSUInteger start = 0, end = 0;
    NSRange range, lineRange;
    NSString *line;
    NSMutableString *paragraph = nil;
    NSCharacterSet *newlineCharset = [NSCharacterSet newlineCharacterSet];

    for (range = NSMakeRange(0, 0); end < length; range.location = end)
    {
        [contents getLineStart: &start
                           end: &end
                   contentsEnd: NULL
                      forRange: range];
        lineRange = NSMakeRange(start, end - start);
        line = [[contents substringWithRange: lineRange] stringByTrimmingCharactersInSet: newlineCharset];
        if (inParagraph)
        {
            if ([line length] == 0) {
                inParagraph = NO;
                outputParagraph(output, paragraph);
            }
            else if ([line hasPrefix: @"＝"] || [line hasPrefix: @"*"] || [line hasPrefix: @"＊"]) {
                inParagraph = NO;
                outputParagraph(output, paragraph);
                outputLine(output, line);
            }
            else if ([line hasPrefix: @"　"] || [line hasPrefix: @"    "]) {
                outputParagraph(output, paragraph);
                paragraph = [[NSMutableString alloc] initWithString: [self firstLine: line]];
            }
            else
                [paragraph appendString: line];
        } else {
            if ([line hasPrefix: @"　"] || [line hasPrefix: @"    "])
            {
                inParagraph = YES;
                paragraph = [[NSMutableString alloc] initWithString: [self firstLine: line]];
            } else {
                outputLine(output, line);
            }
        }
    }

    if (inParagraph && paragraph && [paragraph length]) {
        outputParagraph(output, paragraph);
    }
}

#define TT_APPEND(attrStr, rawStr, ftu) { \
    NSAttributedString *toAppend = [[NSAttributedString alloc] initWithString: rawStr \
                                                                   attributes: [NSDictionary dictionaryWithObject: (__bridge id) ftu \
                                                                                                           forKey: (id) kCTFontAttributeName]]; \
    [str appendAttributedString: toAppend]; \
}

#define TT_APPEND_TEXT(attrStr, textData, textSize, fontToUse) { \
    NSString *rawStr = [[NSString alloc] initWithBytesNoCopy: textData \
                                                      length: textSize \
                                                    encoding: NSUTF8StringEncoding \
                                                freeWhenDone: NO]; \
    TT_APPEND(attrStr, rawStr, fontToUse); \
}

static void tt_header(struct buf *ob, struct buf *text, int level, void *opaque)
{
    struct tt_format_data *data = (struct tt_format_data *) opaque;
    NSMutableAttributedString *str = data->str;
    CTFontRef font = NULL;
    switch(level) {
        case 1:
            if (!data->h1Font)
                data->h1Font = CTFontCreateCopyWithSymbolicTraits(data->normalFont,
                                                                  CTFontGetSize(data->normalFont) + 8,
                                                                  NULL, kCTFontBoldTrait, kCTFontBoldTrait);
            font = data->h1Font;
            break;
        case 2:
            if (!data->h2Font)
                data->h2Font = CTFontCreateCopyWithSymbolicTraits(data->normalFont,
                                                                  CTFontGetSize(data->normalFont) + 6,
                                                                  NULL, kCTFontBoldTrait, kCTFontBoldTrait);
            font = data->h2Font;
            break;
        case 3:
            if (!data->h3Font)
                data->h3Font = CTFontCreateCopyWithSymbolicTraits(data->normalFont,
                                                                  CTFontGetSize(data->normalFont) + 4,
                                                                  NULL, kCTFontBoldTrait, kCTFontBoldTrait);
            font = data->h3Font;
            break;
        case 4:
            if (!data->h4Font)
                data->h4Font = CTFontCreateCopyWithSymbolicTraits(data->normalFont,
                                                                  CTFontGetSize(data->normalFont) + 2,
                                                                  NULL, kCTFontBoldTrait, kCTFontBoldTrait);
            font = data->h4Font;
            break;
    }
    if (text && font) {
        TT_APPEND_TEXT(str, text->data, text->size, font);
    }
    TT_APPEND(str, @"\n", data->normalFont);
}

static void tt_paragraph(struct buf *ob, struct buf *text, void *opaque)
{
    struct tt_format_data *data = (struct tt_format_data *) opaque;
    NSMutableAttributedString *str = data->str;
    if (ob->size) {
        TT_APPEND(str, @"\n", data->normalFont);
    }

    if (text)
        TT_APPEND_TEXT(str, text->data, text->size, data->normalFont);

    TT_APPEND(str, @"\n", data->normalFont);
}

/* renderer structure */
struct mkd_renderer to_textus = {
    /* document-level callbacks */
    NULL,
    NULL,

    /* block-level callbacks */
    NULL,
    NULL,
    NULL,
    tt_header,
    NULL,
    NULL,
    NULL,
    tt_paragraph,
    NULL,
    NULL,
    NULL,

    /* span-level callbacks */
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,

    /* low-level callbacks */
    NULL,
    NULL,

    /* renderer data */
    64,
    "*_",
    NULL
};

- (BOOL) readFromURL: (NSURL *) absoluteURL
              ofType: (NSString *) typeName
               error: (NSError **) outError
{
    NSString *contents;
    NSData *data = [NSData dataWithContentsOfURL: absoluteURL];

    contents = [[NSString alloc] initWithData: data
                                     encoding: detectedEncodingForData(data)];
    if (! contents)
        return NO;


    NSMutableString *wrappedText = [[NSMutableString alloc] init];
    [self outputTo: wrappedText from: [contents stringByReplacingOccurrencesOfString: @"\r"
                                                                          withString: @""]];
    struct buf *ib, *ob;
    ib = bufnew(wrappedText.length);
    bufgrow(ib, wrappedText.length);
    bufputs(ib, [wrappedText UTF8String]);

    NSDictionary *attributes = [self attributesForText];
    struct tt_format_data formatData;
    fileContents = [[NSMutableAttributedString alloc] init];
    formatData.str = fileContents;
    formatData.normalFont = (__bridge CTFontRef) attributes[(id) kCTFontAttributeName];
    formatData.h1Font = formatData.h2Font = formatData.h3Font = NULL;

    ob = bufnew(64);
    to_textus.opaque = &formatData;
    markdown(ob, ib, &to_textus);

    [self setFileContentsInPlainText: [fileContents mutableString]];

    NSArray *keys = [absoluteURL allXattrKeys];
    if ([keys containsObject: kLastReadLocationKey])
        lastReadLocation = [absoluteURL unsignedIntegerFromXattrKey: kLastReadLocationKey];

    return YES;
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

- (NSSize)window:(NSWindow *)window willUseFullScreenContentSize:(NSSize)proposedSize
{
    return NSMakeSize(textView.frame.size.width, proposedSize.height);
}

@end
