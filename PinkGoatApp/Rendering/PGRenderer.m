//
//  PGRenderer.m
//  PinkGoatApp
//
//  Created by Roy Li on 10/3/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import "PGRenderer.h"
#import "PGMathUtilities.h"
//#import "PGDataTypes.h"

typedef uint16_t PGIndex;
//const MTLIndexType PGIndexType = MTLIndexTypeUInt16;

typedef struct
{
    matrix_float4x4 modelViewProjectionMatrix;
} PGUniforms;

@interface PGRenderer()

@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (assign) vector_uint2 viewportSize;
@property (nonatomic, strong) NSData *vertexData;
@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;
@property (nonatomic, strong) id<MTLBuffer> indexBuffer;
@property (nonatomic, strong) id<MTLBuffer> uniformBuffer;
@property (assign) NSUInteger numVertices;

// TODO: move this shape specific data into shapes themselves.
@property (assign) float rotationX;
@property (assign) float rotationY;

@property (nonatomic, strong) NSMutableArray<PGShape *> *shapes;

@end


@implementation PGRenderer

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView;
{
    self = [super init];
    if (self)
    {
        _shapes = [[NSMutableArray alloc] init];
        NSError *error = NULL;
        _device = mtkView.device;
        
        // Load all the shader files with a .metal file extension in the project
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        
        // Load the vertex function from the library
        id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertex_project"];
        
        // Load the fragment function from the library
        id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragment_flatcolor"];
        
        // Configure a pipeline descriptor that is used to create a pipeline state
        MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        pipelineStateDescriptor.label = @"Simple Pipeline";
        pipelineStateDescriptor.vertexFunction = vertexFunction;
        pipelineStateDescriptor.fragmentFunction = fragmentFunction;
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
//        pipelineStateDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;

        _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                                 error:&error];
        if (!_pipelineState)
        {
            // Pipeline State creation could fail if we haven't properly set up our pipeline descriptor.
            //  If the Metal API validation is enabled, we can find out more information about what
            //  went wrong.  (Metal API validation is enabled by default when a debug build is run
            //  from Xcode)
            NSLog(@"Failed to created pipeline state, error %@", error);
            return nil;
        }
        
        // Create the command queue
        _commandQueue = [_device newCommandQueue];
    }
    
    return self;

}

- (void)drawInMTKView:(nonnull MTKView *)view
{
    [self updateUniformsWithDrawable:view.drawableSize];
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"draw buffer";
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if(renderPassDescriptor != nil)
    {
        id<MTLRenderCommandEncoder> renderEncoder =
        [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"MyRenderEncoder";
        
        [renderEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
        [renderEncoder setCullMode:MTLCullModeBack];
        [renderEncoder setRenderPipelineState:_pipelineState];
        [renderEncoder setVertexBuffer:self.uniformBuffer offset:0 atIndex:PGVertexInputIndexUniforms];

        for (PGShape *shape in self.shapes) {
            [shape drawWithCommandEncoder:renderEncoder device:self.device];
        }
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];

    }
    [commandBuffer commit];
    
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

- (void)renderShapes
{
    
}

- (void)registerShape:(nonnull PGShape *)shape
{
    [self.shapes addObject:shape];
    
//    PGVertex vertices[shape.vertices.count];
//    uint16_t indices[shape.vertices.count];
//    [shape makeVertices:&vertices[0] indices:&indices[0] count:shape.vertices.count];
//
//    NSUInteger dataSize = sizeof(vertices);
//    NSMutableData *vertexData = [[NSMutableData alloc] initWithLength:dataSize];
//    memcpy(vertexData.mutableBytes, vertices, sizeof(vertices));
//    NSLog(@"Now we have %lu bytes of data", vertexData.length);
//    self.vertexData = [NSData dataWithBytes:vertexData.bytes length:vertexData.length];
//    self.vertexBuffer = [self.device newBufferWithLength:self.vertexData.length
//                                                 options:MTLResourceStorageModeShared];
//    self.vertexBuffer.label = @"Vertex Buffer";
//    memcpy(self.vertexBuffer.contents, vertexData.mutableBytes, vertexData.length);
//    self.numVertices = vertexData.length / sizeof(PGVertex);
//    self.indexBuffer = [self.device newBufferWithLength:sizeof(indices)
//                                                options:MTLResourceStorageModeShared];
//    self.indexBuffer.label = @"Index Buffer";
//    memcpy(self.indexBuffer.contents, indices, sizeof(indices));
}

// TODO: for now, let's ignore duration as we are not animating things.
// This method will create the uniform buffer
- (void)updateUniformsWithDrawable:(CGSize)drawableSize
{
    self.uniformBuffer = [self.device newBufferWithLength:sizeof(PGUniforms)
                                                  options:MTLResourceStorageModeShared];
    self.uniformBuffer.label = @"Uniform Buffer";
    
    // Make model matrix
    float duration = 0.01;
    self.rotationX += duration * (M_PI / 2);
    self.rotationY += duration * (M_PI / 3);
    const vector_float3 xAxis = { 1, 0, 0 };
    const vector_float3 yAxis = { 0, 1, 0 };
    const matrix_float4x4 xRot = matrix_float4x4_rotation(xAxis, self.rotationX);
    const matrix_float4x4 yRot = matrix_float4x4_rotation(yAxis, self.rotationY);
    const matrix_float4x4 modelMatrix = matrix_multiply(xRot, yRot);
    
    const vector_float3 cameraTranslation = { 0, 0, -3 };
    const matrix_float4x4 viewMatrix = matrix_float4x4_translation(cameraTranslation);
    const float aspect = drawableSize.width / drawableSize.height;
    const float fov = (2 * M_PI) / 5;
    const float near = 1;
    const float far = 100;
    const matrix_float4x4 projectionMatrix = matrix_float4x4_perspective(aspect, fov, near, far);
    PGUniforms uniforms;
    uniforms.modelViewProjectionMatrix = matrix_multiply(projectionMatrix, matrix_multiply(viewMatrix, modelMatrix));
    memcpy(self.uniformBuffer.contents, &uniforms, sizeof(uniforms));
}

@end
