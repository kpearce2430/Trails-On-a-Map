//
//  Trails_On_a_MapTests.m
//  Trails On a MapTests
//
//  Created by KEITH PEARCE on 10/15/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TOMDistance.h"

@interface Trails_On_a_MapTests : XCTestCase

@end

@implementation Trails_On_a_MapTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    NSString *p = nil;
    XCTAssertNil(p, @"p is nil" );
    // XCTPass(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    CLLocationCoordinate2D p1Coord = CLLocationCoordinate2DMake(34.06937608, -84.25335864);
    CLLocationCoordinate2D p2Coord = CLLocationCoordinate2DMake(34.06969865, -84.25232029);
    
    // CLLocation *p1 = [[CLLocation alloc] initWithLatitude:34.06937608 longitude:-84.25335864];
    CLLocation *p1 = [[CLLocation alloc] initWithCoordinate:p1Coord altitude:300.0f horizontalAccuracy:0.0f verticalAccuracy:0.0f timestamp:Nil];
    
    CLLocation *p2 = [[CLLocation alloc] initWithCoordinate:p2Coord altitude:300.0f horizontalAccuracy:0.0f verticalAccuracy:0.0f timestamp:Nil];
    
    CLLocation *p3 = [[CLLocation alloc] initWithCoordinate:p2Coord altitude:1300.0f horizontalAccuracy:0.0f verticalAccuracy:0.0f timestamp:Nil];
    
    CLLocationDistance dist = [TOMDistance distanceFrom:p1 To:p2];
    NSLog(@"Distance:%.3f",dist);
    XCTAssertNotEqual(dist, 0.00F, @"dist p1->p2 = Zero");
    
    dist = [TOMDistance distanceFrom:p2 To:p3];
    NSLog(@"Distance:%.3f",dist);
    XCTAssertNotEqual(dist, 0.00F, @"dist p1->p2+1000m = Zero");
    
    CLLocationCoordinate2D p3Coord = CLLocationCoordinate2DMake(41.756192 , -87.967360);
    CLLocationCoordinate2D p4Coord = CLLocationCoordinate2DMake(41.758701 , -87.973307);
    
    p3 = [[CLLocation alloc] initWithCoordinate:p3Coord altitude:192.0f horizontalAccuracy:0.0f verticalAccuracy:0.0f timestamp:Nil];
    CLLocation *p4 = [[CLLocation alloc] initWithCoordinate:p4Coord altitude:198.0f horizontalAccuracy:0.0f verticalAccuracy:0.0f timestamp:Nil];
    
    dist = [TOMDistance distanceFrom:p3 To:p4];
    NSLog(@"P3->P4 DISTANCE: %.2F",dist);
    XCTAssertNotEqual(dist, 0.0f, @"dist p3->p4  Zero");
}

@end
