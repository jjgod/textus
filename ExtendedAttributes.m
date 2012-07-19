//
//  ExtendedAttributes.m
//  Textus
//
//  Created by Jiang Jiang on 9/18/09.
//

#import "ExtendedAttributes.h"
#import <sys/xattr.h>

@implementation NSURL (ExtendedAttributes)

- (NSArray *) allXattrKeys
{
    NSMutableArray *allKeys = [NSMutableArray array];
    size_t dataSize = listxattr([[self path] fileSystemRepresentation], NULL, ULONG_MAX, 0);
    if (dataSize == ULONG_MAX)
        return allKeys; // Empty list.

    NSMutableData *listBuffer = [NSMutableData dataWithLength: dataSize];
    dataSize = listxattr([[self path] fileSystemRepresentation], [listBuffer mutableBytes], [listBuffer length], 0);
    char *nameStart = [listBuffer mutableBytes];
    int x;
    for (x = 0; x < dataSize; x++) {
        if (((char*)[listBuffer mutableBytes])[x] == 0) {
            NSString* str = [NSString stringWithUTF8String: nameStart];
            nameStart = [listBuffer mutableBytes] + x + 1;
            [allKeys addObject: str];
        }
    }

    return allKeys;
}

- (NSUInteger) unsignedIntegerFromXattrKey: (NSString *) key
{
    const char *path = [[self path] fileSystemRepresentation];
    char dataBuf[256];
    size_t dataSize = getxattr(path, [key UTF8String], dataBuf, 256, 0, 0);

    if (dataSize)
    {
        dataBuf[dataSize] = '\0';
        return strtol(dataBuf, NULL, 10);
    }
    return 0;
}

- (void) setUnsignedInteger: (NSUInteger) num forXattrKey: (NSString *) key
{
    const char *path = [[self path] fileSystemRepresentation];
    const char *buf = [[NSString stringWithFormat: @"%lu", num] UTF8String];

    setxattr(path, [key UTF8String], buf, strlen(buf), 0, 0);
}

// -----------------------------------------------------------------------------
//      setData:forKey:atPath:
//              Set the xattr with name key to a block of raw binary data.
//              path is the file whose xattr you want to set.
// -----------------------------------------------------------------------------

- (void)setData: (NSData *)data forXattrKey: (NSString *)key
{
    setxattr([[self path] fileSystemRepresentation], [key UTF8String], [data bytes], [data length], 0, 0);
}

- (NSMutableData *)dataForXattrKey: (NSString *)key
{
    size_t dataSize = getxattr([[self path] fileSystemRepresentation], [key UTF8String], NULL, ULONG_MAX, 0, 0);
    if (dataSize == ULONG_MAX)
        return nil;
    NSMutableData *data = [NSMutableData dataWithLength: dataSize];
    getxattr([[self path] fileSystemRepresentation], [key UTF8String], [data mutableBytes], [data length], 0, 0);
    return data;
}

- (NSString *) stringFromXattrKey: (NSString *) key
{
    NSMutableData *data = [self dataForXattrKey: key];
    return [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
}

- (void) setString: (NSString *) str forXattrKey: (NSString *) key
{
    NSData *data = [str dataUsingEncoding: NSUTF8StringEncoding];

    if (!data)
        [NSException raise: NSCharacterConversionException
                    format: @"Couldn't convert string to UTF8 for xattr storage."];

    [self setData: data forXattrKey: key];
}

@end
