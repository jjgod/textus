//
//  TTProgressView.h
//  Textus
//
//  Created by Jiang Jiang on 7/16/12.
//
//

#import <Cocoa/Cocoa.h>

@interface TTProgressView : NSView {
    IBOutlet NSTextField *statusField;
    NSPoint currentPoint;
}

@end
