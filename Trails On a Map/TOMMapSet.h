//
//  TOMMapSet.h
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/20/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "TOMPomSet.h"

#import <pthread.h>

@interface TOMMapSet : NSObject
{
    MKMapPoint *points;
    NSUInteger pointCount;
    NSUInteger pointSpace;
    MKMapRect boundingMapRect;
    pthread_rwlock_t rwLock;
}

//
// Initialize the Pebble Track with the starting coordinate.
// The Pebble Tracks's boundingMapRect will be set to a sufficiently large square
// centered on the starting coordinate.
//
- (id)initWithCenterCoordinate:(CLLocationCoordinate2D)coord;

// Add a location observation. A MKMapRect containing the newly added point
// and the previously added point is returned so that the view can be updated
// in that rectangle.  If the added coordinate has not moved far enough from
// the previously added coordinate it will not be added to the list and
// MKMapRectNull will be returned.
//
- (MKMapRect)addCoordinate:(CLLocationCoordinate2D)coord;

// The following properties must only be accessed when holding the read lock
// via lockForReading.  Once you're done accessing the points, release the
// read lock with unlockForReading.
//
@property (readonly) MKMapPoint *points;
@property (readonly) NSUInteger pointCount;

- (void)unlockForReading;
- (void)lockForReading;

//  Load points from a PebbleTrackSet:
- (void) loadFromPoms:(TOMPomSet *)pt;
- (BOOL) initWithCoord:(CLLocationCoordinate2D) coord;
- (void) clearPoms;

@end
