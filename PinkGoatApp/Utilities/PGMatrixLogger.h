//
//  PGMatrixLogger.h
//  PinkGoatApp
//
//  Created by Roy Li on 10/23/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <simd/simd.h>

@interface PGMatrixLogger : NSObject

+ (void)printMatrix4x4:(matrix_float4x4)matrix;

@end
