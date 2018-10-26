//
//  PGMTKView.h
//  PinkGoatApp
//
//  Created by Roy Li on 10/26/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <MetalKit/MetalKit.h>
#import <simd/simd.h>
#import "PGMTKControlDelegate.h"

@interface PGMTKView : MTKView

@property (nonatomic, weak) id<PGMTKViewControlDelegate> controlDelegate;

@end
