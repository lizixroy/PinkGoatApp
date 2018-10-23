//
//  PGShapeTests.m
//  PinkGoatAppTests
//
//  Created by Roy Li on 10/8/18.
//  Copyright © 2018 Roy Li. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PGShape.h"
#import <simd/simd.h>
#import "PGVertexObject.h"

@interface PGShapeTests : XCTestCase

@end

@implementation PGShapeTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMakeVertices
{
    vector_float4 position1 = { 1.0, 1.0, 1.0, 1.0 };
    vector_float3 normal1 = { 0.0, 0.0, 0.0 };
    vector_float4 color1 = { 1.1, 1.1, 1.1, 1.1 };
    PGVertexObject *vertex1 = [[PGVertexObject alloc] initWithPosition:position1
                                                                normal: normal1
                                                                 color: color1];
    vector_float4 position2 = { 2.0, 2.0, 2.0, 1.0 };
    vector_float3 normal2 = { 0.0, 0.0, 0.0 };
    vector_float4 color2 = { 1.2, 1.2, 1.2, 1.2 };
    PGVertexObject *vertex2 = [[PGVertexObject alloc] initWithPosition:position2
                                                                normal:normal2
                                                                 color:color2];
    NSArray<PGVertexObject *> *vertices = @[vertex1, vertex2];
    PGShape *shape = [[PGShape alloc] initWithVertices:vertices indices:nil];
    PGVertex vertexBuffer[shape.vertices.count];
    [shape makeVertices:&vertexBuffer[0] count:shape.vertices.count];
    
    PGVertex vertex = vertexBuffer[0];
    
    vector_float4 expectedPosition1 = { 1.0, 1.0, 1.0, 1.0 };
    XCTAssertEqual(vertex.position.x, expectedPosition1.x);
    XCTAssertEqual(vertex.position.y, expectedPosition1.y);
    XCTAssertEqual(vertex.position.z, expectedPosition1.z);
    XCTAssertEqual(vertex.position.w, expectedPosition1.w);
    vector_float4 expectedColor1 = { 1.1, 1.1, 1.1, 1.1 };
    XCTAssertEqual(vertex.color.x, expectedColor1.x);
    XCTAssertEqual(vertex.color.y, expectedColor1.y);
    XCTAssertEqual(vertex.color.z, expectedColor1.z);
    XCTAssertEqual(vertex.color.w, expectedColor1.w);
    
    PGVertex v2 = vertexBuffer[1];

    vector_float4 expectedPosition2 = { 2.0, 2.0, 2.0, 1.0 };
    XCTAssertEqual(v2.position.x, expectedPosition2.x);
    XCTAssertEqual(v2.position.y, expectedPosition2.y);
    XCTAssertEqual(v2.position.z, expectedPosition2.z);
    XCTAssertEqual(v2.position.w, expectedPosition2.w);
    vector_float4 expectedColor2 = { 1.2, 1.2, 1.2, 1.2 };
    XCTAssertEqual(v2.color.x, expectedColor2.x);
    XCTAssertEqual(v2.color.y, expectedColor2.y);
    XCTAssertEqual(v2.color.z, expectedColor2.z);
    XCTAssertEqual(v2.color.w, expectedColor2.w);
    


}


@end
