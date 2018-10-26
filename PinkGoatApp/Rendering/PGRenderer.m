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
#import "PGCamera.h"

const vector_float3 START_POSITION = { 0.0, -3.0, 0.0 };
const vector_float3 START_CAMERA_VIEW_DIR = { 0.0, -1.0, 0.0 };
const vector_float3 START_CAMERA_UP_DIR = { 0.0, 0.0, 1.0 };

typedef uint16_t PGIndex;

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
@property (nonatomic, strong) NSMutableArray<PGShape *> *shapes;
@property (assign) matrix_float4x4 viewProjectionMatrix;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) PGCamera *camera;

// TODO: move this shape specific data into shapes themselves.
@property (assign) float rotationX;
@property (assign) float rotationY;

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
        _camera = [[PGCamera alloc] init];
        _camera.up = START_CAMERA_UP_DIR;
        _camera.direction = START_CAMERA_VIEW_DIR;
        _camera.position = START_POSITION;
        
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
        
        // TODO: adjust semaphore value
        self.semaphore = dispatch_semaphore_create(1);
    }
    
    return self;

}

- (void)drawInMTKView:(nonnull MTKView *)view
{
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
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
            [shape drawWithCommandEncoder:renderEncoder
                                   device:self.device
                     viewProjectionMatrix:self.viewProjectionMatrix
                          parentTransform:matrix_identity_float4x4];
        }
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> _Nonnull buffer) {
        dispatch_semaphore_signal(self.semaphore);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.frameCompletion != nil) {
                self.frameCompletion();
            }
        });
    }];
    [commandBuffer commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

- (void)registerShape:(nonnull PGShape *)shape
{
    [self.shapes addObject:shape];
}

// TODO: for now, let's ignore duration as we are not animating things.
// This method will create the uniform buffer
- (void)updateUniformsWithDrawable:(CGSize)drawableSize
{
    self.uniformBuffer = [self.device newBufferWithLength:sizeof(PGUniforms)
                                                  options:MTLResourceStorageModeShared];
    self.uniformBuffer.label = @"Uniform Buffer";
    const matrix_float4x4 modelMatrix = matrix_identity_float4x4;
    const matrix_float4x4 viewMatrix = [self.camera getViewMatrix];
    const float aspect = drawableSize.width / drawableSize.height;
    const float fov = (2 * M_PI) / 5;
    const float near = 1;
    const float far = 100;
    const matrix_float4x4 projectionMatrix = matrix_float4x4_perspective(aspect, fov, near, far);
    self.viewProjectionMatrix = matrix_multiply(projectionMatrix, matrix_multiply(viewMatrix, modelMatrix));
}

#pragma mark - PGMTKViewControlDelegate
- (void)cameraRotationUpdated:(vector_float2)rotation
{
    // y is the first component and x is the second because the difference occurred in the x direction generates rotation around the Y axis
    // and difference occurred in the y direction generates rotation around the X axis.
    vector_float2 cameraAngles = { 0.005 * rotation.y, 0.005 * rotation.x };
    vector_float2 updatedCameraAngles = { self.camera.cameraAngles.x + cameraAngles.x, self.camera.cameraAngles.y + cameraAngles.y };
    self.camera.cameraAngles = updatedCameraAngles;
}

@end
