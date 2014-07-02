//
//  TOMMapAnnotation.h
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 5/21/14.
//  Copyright (c) 2014 Pearce Software Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "TOMPointOnAMap.h"

@interface TOMMapAnnotation : NSObject <MKAnnotation>
{
    
}

@property (nonatomic, retain) TOMPointOnAMap *mp;

// @property (nonatomic) CLLocationDegrees latitude;
// @property (nonatomic) CLLocationDegrees longitude;

- (id)initWithLatitude:(CLLocationDegrees)latitude
		  andLongitude:(CLLocationDegrees)longitude;

- (id)initWithPoint:(TOMPointOnAMap *) p;

@end
