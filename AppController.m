//
//  AppController.m
//  Textus
//
//  Created by Jjgod Jiang on 3/16/09.
//  Copyright 2009 Jjgod Jiang. All rights reserved.
//

#import "AppController.h"

int hexNum(char ch)
{
    if (ch >= '0' && ch <= '9')
        return ch - '0';

    if (ch >= 'A' && ch <= 'F')
        return ch - 'A' + 10;

    if (ch >= 'a' && ch <= 'f')
        return ch - 'a' + 10;

    return 0;
}

NSColor *decodeColor(NSString *colorString)
{
    const char *cstr = [colorString UTF8String];
    if (strlen(cstr) != 7)
        return [NSColor whiteColor];

    CGFloat red   = (hexNum(cstr[1]) * 16 + hexNum(cstr[2])) / 255.0;
    CGFloat green = (hexNum(cstr[3]) * 16 + hexNum(cstr[4])) / 255.0;
    CGFloat blue  = (hexNum(cstr[5]) * 16 + hexNum(cstr[6])) / 255.0;

    return [NSColor colorWithCalibratedRed:red
                                     green:green
                                      blue:blue
                                     alpha:1.0];
}

NSString *encodeColor(NSColor *color)
{
    return [NSString stringWithFormat: @"#%02X%02X%02X",
            (int) ([color redComponent] * 255.0),
            (int) ([color greenComponent] * 255.0),
            (int) ([color blueComponent] * 255.0)];
}

@implementation AppController

+ (void) initialize
{
	NSMutableDictionary *appDefaults = [NSMutableDictionary dictionary];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [appDefaults setValue: @"#000000" forKey: @"foregroundColor"];
    [appDefaults setValue: @"#FFFFFF" forKey: @"backgroundColor"];
    [appDefaults setValue: @"STKaiti" forKey: @"fontName"];
    [appDefaults setValue: [NSNumber numberWithDouble: 14.0] forKey: @"fontSize"];
    [appDefaults setValue: [NSNumber numberWithDouble: 16.0] forKey: @"lineHeight"];

	[defaults registerDefaults: appDefaults];
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues: appDefaults];
    [[NSColorPanel sharedColorPanel] setShowsAlpha: YES];
}

- (void) awakeFromNib
{
    [[NSFontManager sharedFontManager] setSelectedFont: [self font]
                                            isMultiple: NO];
}

- (NSFont *) font
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [NSFont fontWithName: [defaults stringForKey: @"fontName"]
                           size: [defaults doubleForKey: @"fontSize"]];
}

- (NSColor *) foregroundColor
{
    NSString *colorString = [[NSUserDefaults standardUserDefaults] stringForKey: @"foregroundColor"];
    return decodeColor(colorString);
}

- (void) setForegroundColor: (NSColor *) color
{
    [[NSUserDefaults standardUserDefaults] setValue: encodeColor(color) forKey: @"foregroundColor"];
}

- (NSColor *) backgroundColor
{
    NSString *colorString = [[NSUserDefaults standardUserDefaults] stringForKey: @"backgroundColor"];
    return decodeColor(colorString);
}

- (void) setBackgroundColor: (NSColor *) color
{
    [[NSUserDefaults standardUserDefaults] setValue: encodeColor(color) forKey: @"backgroundColor"];
}

- (BOOL) applicationShouldOpenUntitledFile: (NSApplication *) sender
{
    return NO;
}

- (void) changeFont: (id) sender
{
    NSFont *oldFont = [self font];
    NSFont *newFont = [sender convertFont: oldFont];
    
    NSLog(@"changeFont = %@", newFont);

    [[NSUserDefaults standardUserDefaults] setValue: [newFont fontName] forKey: @"fontName"];
    [[NSUserDefaults standardUserDefaults] setValue: [NSNumber numberWithDouble: [newFont pointSize]] forKey: @"fontSize"];
}

@end
