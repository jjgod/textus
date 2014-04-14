//
//  TTProgressView.m
//  Textus
//
//  Created by Jiang Jiang on 7/16/12.
//

#import "TTProgressView.h"

@implementation TTProgressView

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // TODO: figure out why 50 padding is needed here
    CGFloat width = frame.size.width + 50;
    NSRect rect = NSMakeRect(0, 0, width, frame.size.height);
    NSTrackingAreaOptions options = NSTrackingMouseEnteredAndExited |
				    NSTrackingMouseMoved |
				    NSTrackingActiveInKeyWindow;
    NSTrackingArea* trackingArea = [[NSTrackingArea alloc] initWithRect:rect
								options:options
								  owner:self
							       userInfo:nil];
    [self addTrackingArea:trackingArea];
  }

  return self;
}

- (void)mouseEntered:(NSEvent*)theEvent {
  [[self window] setAcceptsMouseMovedEvents:YES];
}

- (void)mouseMoved:(NSEvent*)theEvent {
  currentPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
  [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent*)theEvent {
  [[self window] setAcceptsMouseMovedEvents:NO];
}

- (void)drawRect:(NSRect)dirtyRect {
  // Drawing code here.
  [[NSColor darkGrayColor] setFill];
  CGFloat width = self.frame.size.width / 50;
  int i;
  CGFloat r;
  int p = [statusField integerValue];
  bool unread = false;
  for (i = 1; i < 50; i++) {
    if (p < i * 2 && !unread) {
      [[NSColor lightGrayColor] setFill];
      unread = true;
    }
    r = 3;
    if (ABS(currentPoint.x - i * width) < 5)
      r = 6;
    // Create our circle path
    NSRect rect = NSMakeRect(i * width - r / 2, 8.5 - r / 2, r, r);
    NSBezierPath* circlePath = [NSBezierPath bezierPath];
    [circlePath appendBezierPathWithOvalInRect:rect];
    [circlePath fill];
  }
}

@end
