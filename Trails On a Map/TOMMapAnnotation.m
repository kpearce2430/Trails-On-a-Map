//
//  TOMMapAnnotation.m
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 5/21/14.
//  Copyright (c) 2014 Pearce Software Solutions. All rights reserved.
//

#import "TOMMapAnnotation.h"

@implementation TOMMapAnnotation

@synthesize coordinate;

- (id)initWithLatitude:(CLLocationDegrees)latitude
		  andLongitude:(CLLocationDegrees)longitude {
	if (self = [super init]) {
        coordinate.latitude = latitude;
        coordinate.longitude = longitude;
	}
	return self;
}

- (id)initWithPoint:(TOMPointOnAMap *) tomPoint {
    
    if  (self = [super init]) {
        [self setMp:tomPoint];
    }
    
    return self;
}

@end
