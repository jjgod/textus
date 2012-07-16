//
//  TTProgressView.m
//  Textus
//
//  Created by Jiang Jiang on 7/16/12.
//
//

#import "TTProgressView.h"

@implementation TTProgressView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }

    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    [[NSColor darkGrayColor] setFill];
    CGFloat width = self.frame.size.width / 50;
    int i;
    int p = [statusField integerValue];
    bool unread = false;
    for (i = 1; i < 50; i++) {
        if (p < i * 2 && !unread) {
            [[NSColor lightGrayColor] setFill];
            unread = true;
        }
        // Create our circle path
        NSRect rect = NSMakeRect(i * width, 7, 3, 3);
        NSBezierPath *circlePath = [NSBezierPath bezierPath];
        [circlePath appendBezierPathWithOvalInRect: rect];
        [circlePath fill];
    }
}

@end
