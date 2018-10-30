//
//  NSColor+Vector.h
//  PinkGoatApp
//
//  Created by Roy Li on 10/28/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <simd/simd.h>

@interface NSColor (Vector)

- (vector_float4)vectorForm;

@end
