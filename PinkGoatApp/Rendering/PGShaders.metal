//
//  PGShaders.metal
//  PinkGoatApp
//
//  Created by Roy Li on 10/4/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

#import "PGShaderTypes.h"

struct Light
{
    float3 direction;
    float3 ambientColor;
    float3 diffuseColor;
    float3 specularColor;
    float3 position;
};

constant Light light = {
    .direction = { 0.13, 0.72, 0.68 },
    .ambientColor = { 0.05, 0.05, 0.05 },
    .diffuseColor = { 1, 1, 1 },
    .specularColor = { 1, 1, 1 },
    .position = { 0.0, 0.0, 225.0 }
    
};

struct Material
{
    float3 ambientColor;
    float3 diffuseColor;
    float3 specularColor;
    float specularPower;
};

constant Material material = {
    .ambientColor = { 0.9, 0.1, 0 },
    .diffuseColor = { 1, 1, 1 },
    .specularColor = { 1, 1, 1 },
    .specularPower = 100
};


// Vertex shader outputs and fragment shader inputs
typedef struct
{
    // The [[position]] attribute qualifier of this member indicates this value is the clip space
    //   position of the vertex wen this structure is returned from the vertex shader
    float4 clipSpacePosition [[position]];
    
    // Since this member does not have a special attribute qualifier, the rasterizer will
    //   interpolate its value with values of other vertices making up the triangle and
    //   pass that interpolated value to the fragment shader for each fragment in that triangle
    float4 color;
    
} RasterizerData;


// Vertex function
vertex RasterizerData
vertexShader(uint vertexID [[ vertex_id ]],
             device PGVertex *vertices [[ buffer(PGVertexInputIndexVertices) ]],
             constant vector_uint2 *viewportSizePointer  [[ buffer(PGVertexInputIndexUniforms) ]])
{
    RasterizerData out;
    
    // Initialize our output clip space position
    out.clipSpacePosition = vector_float4(0.0, 0.0, 0.0, 1.0);
    
    // Index into our array of positions to get the current vertex
    //   Our positions are specified in pixel dimensions (i.e. a value of 100 is 100 pixels from
    //   the origin)
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    
    // Dereference viewportSizePointer and cast to float so we can do floating-point division
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);
    
    // The output position of every vertex shader is in clip space (also known as normalized device
    //   coordinate space, or NDC).   A value of (-1.0, -1.0) in clip-space represents the
    //   lower-left corner of the viewport whereas (1.0, 1.0) represents the upper-right corner of
    //   the viewport.
    
    // Calculate and write x and y values to our clip-space position.  In order to convert from
    //   positions in pixel space to positions in clip-space, we divide the pixel coordinates by
    //   half the size of the viewport.
    out.clipSpacePosition.xy = pixelSpacePosition / (viewportSize / 2.0);
    
    // Pass our input color straight to our output color.  This value will be interpolated
    //   with the other color values in the vertices that make up the triangle to produce
    //   the color value for each fragment in our fragmentShader
    out.color = vertices[vertexID].color;
    
    return out;
}

// Fragment function
fragment float4 fragmentShader(RasterizerData in [[stage_in]])
{
    // We return the color we just set which will be written to our color attachment.
    return in.color;
}


/* Vertex Shader for 3D graphics */

struct Vertex
{
    vector_float4 position [[position]];
    vector_float3 normal;
    vector_float4 color;
    vector_float3 eye;
};

struct Uniforms
{
    matrix_float4x4 viewProjectionMatrix;
    matrix_float4x4 modelMatrix;
    matrix_float3x3 normalMatrix;
};

vertex Vertex vertex_project(device Vertex *vertices [[buffer(0)]],
                             constant Uniforms *uniforms [[buffer(1)]],
                             uint vid [[vertex_id]])
{
    Vertex vertexOut;
    matrix_float4x4 modelViewProjectionMatrix = uniforms->viewProjectionMatrix * uniforms->modelMatrix;
    vertexOut.position = modelViewProjectionMatrix * vertices[vid].position;
    vertexOut.color = vertices[vid].color;
    vertexOut.normal = uniforms->normalMatrix * vertices[vid].normal;
    vertexOut.eye = -(uniforms->modelMatrix * vertices[vid].position).xyz;
    return vertexOut;
}

fragment float4 fragment_flatcolor(Vertex vertexIn [[stage_in]])
{
    
//    // Ambient term
//    float3 ambientTerm = light.ambientColor * material.ambientColor;
//    // Diffuse term
//    float3 normal = normalize(vertexIn.normal);
//    float diffuseIntensity = saturate(dot(normal, light.direction));
//    float3 diffuseTerm = light.diffuseColor * vertexIn.color.xyz * diffuseIntensity;
//    // Specular term
//    float3 specularTerm(0);
//    if (diffuseIntensity > 0) {
//        float3 eyeDirection = normalize(vertexIn.normal);
//        float3 halfway = normalize(light.direction + eyeDirection);
//        float specularFactor = pow(saturate(dot(normal, halfway)), material.specularPower);
//        specularTerm = light.specularColor * material.specularColor * specularFactor;
//    }
//    return float4(ambientTerm + diffuseTerm, 1);
    
    float3 L = normalize(light.position.xyz);
    float attenuation = clamp(dot(normalize(vertexIn.normal), L), 0.3, 1.0);

//    float attenuation = clamp(dot(normalize(input.worldSpaceNormal), L), 0.3, 1.0);
    float3 color = vertexIn.color.xyz*attenuation;
//    return float4(color, 1.0);
    
    return float4(color, 1.0);
}
