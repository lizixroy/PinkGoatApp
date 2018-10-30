//
//  PGRenderer.m
//  PinkGoatApp
//
//  Created by Roy Li on 10/3/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGRenderer.h"
#import "PGMathUtilities.h"
#import "PGShaderTypes.h"

@implementation PGRenderer

#pragma mark - SCNSceneRendererDelegate

- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time
{
    if (self.frameCompletion != nil) {
        self.frameCompletion();
    }
}

@end
