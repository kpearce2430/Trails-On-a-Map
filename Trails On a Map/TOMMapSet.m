//
//  TOMMapSet.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/20/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import "TOMMapSet.h"

@implementation TOMMapSet

@synthesize points, pointCount;

- (id) init
{
    self = [super init];
    if (self) {
        // initialize point storage and place this first coordinate in it
        if (!points) {
            pointSpace = INITIAL_POINT_SPACE;
            points = malloc(sizeof(MKMapPoint) * pointSpace);
        }
        pointCount = 0;
    }
    return self;
}

- (BOOL) initWithCoord:(CLLocationCoordinate2D) coord
{
    if (pointSpace > 0) {
        //
        // I know that I'm leaving points in the array
        // when I convert this over to MKPolyLine, this old
        // code will go away
        //
        points[0] = MKMapPointForCoordinate(coord);
        pointCount = 1;
        return YES;
    }
    else
        return NO;
}

- (id)initWithCenterCoordinate:(CLLocationCoordinate2D)coord
{
	self = [super init];
    if (self)
	{
        // initialize point storage and place this first coordinate in it
        if (!points) {
            pointSpace = INITIAL_POINT_SPACE;
            points = malloc(sizeof(MKMapPoint) * pointSpace);
        }
        points[0] = MKMapPointForCoordinate(coord);
        pointCount = 1;
        
        // bite off up to 1/4 of the world to draw into.
        MKMapPoint origin = points[0];
        origin.x -= MKMapSizeWorld.width / 8.0;
        origin.y -= MKMapSizeWorld.height / 8.0;
        MKMapSize size = MKMapSizeWorld;
        size.width /= 4.0;
        size.height /= 4.0;
        boundingMapRect = (MKMapRect) { origin, size };
        MKMapRect worldRect = MKMapRectMake(0, 0, MKMapSizeWorld.width, MKMapSizeWorld.height);
        boundingMapRect = MKMapRectIntersection(boundingMapRect, worldRect);
        
        // initialize read-write lock for drawing and updates
        pthread_rwlock_init(&rwLock, NULL);
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return MKCoordinateForMapPoint(points[0]);
}

- (MKMapRect)boundingMapRect
{
    return boundingMapRect;
}

- (void)lockForReading
{
    pthread_rwlock_rdlock(&rwLock);
}

- (void)unlockForReading
{
    pthread_rwlock_unlock(&rwLock);
}

- (MKMapRect)addCoordinate:(CLLocationCoordinate2D)coord
{
    // Acquire the write lock because we are going to be changing the list of points
    pthread_rwlock_wrlock(&rwLock);
    
    // Convert a CLLocationCoordinate2D to an MKMapPoint
    MKMapPoint newPoint = MKMapPointForCoordinate(coord);
    MKMapPoint prevPoint = points[pointCount - 1];
    
    // Get the distance between this new point and the previous point.
    CLLocationDistance metersApart = MKMetersBetweenMapPoints(newPoint, prevPoint);
    MKMapRect updateRect = MKMapRectNull;
    
    if (metersApart > MINIMUM_DELTA_METERS)
    {
        // Grow the points array if necessary
        if (pointSpace == pointCount)
        {
            pointSpace *= 2;
            points = realloc(points, sizeof(MKMapPoint) * pointSpace);
        }
        
        // Add the new point to the points array
        points[pointCount] = newPoint;
        pointCount++;
        
        // Compute MKMapRect bounding prevPoint and newPoint
        double minX = MIN(newPoint.x, prevPoint.x);
        double minY = MIN(newPoint.y, prevPoint.y);
        double maxX = MAX(newPoint.x, prevPoint.x);
        double maxY = MAX(newPoint.y, prevPoint.y);
        
        updateRect = MKMapRectMake(minX , minY , (maxX - minX) , (maxY - minY) );
    }
    
    // updateRect = MKMapRectOffset( updateRect, 100000.0, 100000.0 );
    pthread_rwlock_unlock(&rwLock);
    
    return updateRect;
}

- (void) loadFromPoms:(TOMPomSet *)pt
{
    //
    //
    for (NSInteger i = 0 ; i < [pt.ptTrack count]; i++ )   {
        TOMPointOnAMap *mp = [pt.ptTrack objectAtIndex: i];
        CLLocationCoordinate2D coord = [mp coordinate];
        if (i == 0) {
            if (![self initWithCenterCoordinate:coord]) {
                NSLog(@"Something went wrong");
            }
        }
        else {
            
            [self addCoordinate:coord];
            
#ifdef __NUA__
            MKMapPoint newPoint = MKMapPointForCoordinate(coord);
            MKMapPoint prevPoint = points[pointCount - 1];
            // Get the distance between this new point and the previous point.
            CLLocationDistance metersApart = MKMetersBetweenMapPoints(newPoint, prevPoint);
            if (metersApart > MINIMUM_DELTA_METERS)
            {
                // Grow the points array if necessary
                if (pointSpace == pointCount)
                {
                    pointSpace *= 2;
                    points = realloc(points, sizeof(MKMapPoint) * pointSpace);
                }
                
                // Add the new point to the points array
                points[pointCount] = newPoint;
                pointCount++;
            }
#endif

        }
    }
    return;
}

- (void) clearPoms {
    pointCount = 0;
}

@end
