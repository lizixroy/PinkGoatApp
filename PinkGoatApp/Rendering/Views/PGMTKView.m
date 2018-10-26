//
//  PGMTKView.m
//  PinkGoatApp
//
//  Created by Roy Li on 10/26/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGMTKView.h"
#import <simd/simd.h>

@interface PGMTKView()

@property (assign) CGPoint mouseDownPoint;

@end

@implementation PGMTKView

- (void)mouseDown:(NSEvent *)event
{
    if (event.modifierFlags & NSEventModifierFlagControl) {
        self.mouseDownPoint = event.locationInWindow;
    }
}

- (void)mouseDragged:(NSEvent *)event
{
    if (event.modifierFlags & NSEventModifierFlagControl) {
        CGPoint point = event.locationInWindow;
        float rotationX = point.x - self.mouseDownPoint.x;
        float rotationY = point.y - self.mouseDownPoint.y;
        vector_float2 rotation = { rotationX, rotationY };
        if (self.controlDelegate != nil) {
            [self.controlDelegate cameraRotationUpdated:rotation];
        }
        self.mouseDownPoint = point;
    }
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

@end
