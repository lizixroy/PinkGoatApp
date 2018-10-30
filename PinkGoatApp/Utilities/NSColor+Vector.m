//
//  NSColor+Vector.m
//  PinkGoatApp
//
//  Created by Roy Li on 10/28/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "NSColor+Vector.h"

@implementation NSColor (Vector)

- (vector_float4)vectorForm;
{
    vector_float4 vector = { self.redComponent, self.greenComponent, self.blueComponent, self.alphaComponent };
    return vector;
}

@end
