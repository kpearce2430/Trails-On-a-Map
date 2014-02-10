//
//  TOMPomSet.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/18/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import "TOMPomSet.h"

@implementation TOMPomSet


@synthesize ptTrack, /* ptProperties, */ ptMapRect;

//
// * * * * * * * * * * * * * * * * * * * * * *
//
- (id)initWithTitle: (NSString *) t
{
    self = [super init];
    
    if (self)
    {
        ptTrack = [[NSMutableArray alloc] init];
    }
    return self;
}

//
// * * * * * * * * * * * * * * * * * * * * * *
//
- (void)addPointOnMap:(TOMPointOnAMap *) p;
{
    [ptTrack addObject:p];
}

//
// Last Point On A Map
- (TOMPointOnAMap *)lastPom
{
    return [ptTrack lastObject];
}

//
// * * * * * * * * * * * * * * * * * * * * * *
//
//
// Debugging...
//
- (void)listPoms
{
    // Let's dump the bread crumbs and see what we have;
    TOMPointOnAMap *mp;
    CLLocationCoordinate2D coord;
    CLLocationDistance alt;
    CLHeading *hdng;
    
    // NSLog(@"%@ Count[%ld]", [ptProperties ptName], (unsigned long)[ptTrack count] );
    
    for ( int i = 0 ; i < [ptTrack count] ; i++ )
    {
        // NSLog(@"%@", [breadCrumbTrack objectAtIndex: i] );
        mp = [ptTrack objectAtIndex: i];
        coord = [ mp coordinate ];
        alt = [mp altitude];
        hdng = [mp heading];
        
        NSLog(@"T<%@> LL<%.4f %.4f> Alt:%.1f", mp.timestamp, coord.latitude, coord.longitude, alt  );
        // NSLog(@"%@",[hdng description]);
    }
}

//
// * * * * * * * * * * * * * * * * * * * * * *
//
-(NSString *) tomArchivePathWithTitle:(NSString *)title
{
    
    if (!title ||
        [title isEqualToString:@""] )
    {
        NSLog(@"NULL or Empty String passed to pebblesArchivePathWithTitle");
        return NULL;
    }
    
    // According to BNR, the last two arguments are always the same
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *fileName = [title stringByAppendingString:@TOM_FILE_EXT];
    
    // Get one and only one document directory
    NSString *documentDirectory = [ documentDirectories objectAtIndex:0];

    //
    // I'm letting the calling method determine what to do the pebbles if
    // the default name is used.
    //
    return [documentDirectory stringByAppendingPathComponent:fileName];
}

//
// * * * * * * * * * * * * * * * * * * * * * *
//
-(NSString *) tomArchivePath
{
    NSString *newTitle;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_NAME] != nil)
    {
        newTitle = [[NSUserDefaults standardUserDefaults] stringForKey:@KEY_NAME];
        return [self tomArchivePathWithTitle: newTitle];
    }
    else
        return NULL;
}

//
// * * * * * * * * * * * * * * * * * * * * * *
//
- (BOOL) savePoms:(NSString *)title
{
    NSString *path = NULL;
    NSData * archivedTrack = [NSKeyedArchiver archivedDataWithRootObject:ptTrack];
    
    if (title)
        path = [self tomArchivePathWithTitle:title];
    else
        path = [ self tomArchivePath ];
    
    NSError *error;
    [archivedTrack writeToFile:path options:NSDataWritingFileProtectionNone error:&error];
    
    if (error)
    {
        NSLog(@"%@",error );
        return NO;
    }
    else
        return YES;
}

//
// * * * * * * * * * * * * * * * * * * * * * *
//
- (BOOL) loadPoms:(NSString *)title
{
    NSString *path = NULL;
    
    if (title)
        path = [self tomArchivePathWithTitle:title];
    else
        path = [ self tomArchivePath ];
    
    //
    // If there is a track and there is one or more poms
    //
    if  (ptTrack && [ptTrack count] > 0)
        [self.ptTrack removeAllObjects];
    
    ptTrack = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    if  (ptTrack) {
        // NSLog(@"YES");
        return YES;
    }
    else {
        // NSLog(@"Nope");
        ptTrack = [[ NSMutableArray alloc] init ];
    }
    
    return NO;
}
//
// * * * * * * * * * * * * * * * * * * * * * *
//
- (BOOL) deletePoms:(NSString *) title
{
    NSString *path = NULL;
    
    if (title)
        path = [self tomArchivePathWithTitle:title];
    else
        path = [self tomArchivePath];
    
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath: path error: &error];

    if (error)
    {
        NSLog(@"%@",error );
        return NO;
    }
    else
        return YES;
}

//
// Check to see if there is a track.
//
- (BOOL) areTherePoms
{
    NSString *path = [ self tomArchivePath ];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

//
// * * * * * * * * * * * * * * * * * * * * * *
//
- (double) distanceTotalMeters {
    
    double totalDist = 0.00;
    CLLocation *myLocone;
    CLLocation *myLoctwo;
    
    if ([ptTrack count] < 2) {
        // not enough points to calculate distance;
        return 0.00;
    }
    else if ([ptTrack count] == 2 ) {
        return [self distanceStraightLine];
    }
    else {
        TOMPointOnAMap *mp = [ptTrack objectAtIndex: 0];
        myLocone = [mp location];
        
        for (int i = 1; i < [ptTrack count]; i++)
        {
            mp = [ptTrack objectAtIndex:i];
            myLoctwo = [mp location];
            totalDist += [myLocone distanceFromLocation:myLoctwo];
            myLocone = myLoctwo;
        }
    }
    return totalDist;
}
//
// * * * * * * * * * * * * * * * * * * * * * *
//
- (double) distanceStraightLine {
    if ([ptTrack count] < 2) {
        // not enough points to calculate distance;
        return 0.00;
    }
    
    TOMPointOnAMap *mp = [ptTrack objectAtIndex: 0];
    CLLocation *first = [mp location];
    mp = [ptTrack objectAtIndex:[ptTrack count]-1];
    
    CLLocation *last = [mp location];
    
    return [first distanceFromLocation:last];
}

//
// * * * * * * * * * * * * * * * * * * * * * *
//
- (MKCoordinateRegion) ptMakeRegion
{
    // determine the extents of the trip points that were passed in, and zoom in to that area.
    CLLocationDegrees maxLat = -90;
    CLLocationDegrees maxLon = -180;
    CLLocationDegrees minLat = 90;
    CLLocationDegrees minLon = 180;
    
    for (int i = 0; i < [ptTrack count]; i++ )
    {
        TOMPointOnAMap *p = [ptTrack objectAtIndex:i];
        CLLocation *currentLocation = [p location];
        
        if (currentLocation.coordinate.latitude > maxLat)
            maxLat = currentLocation.coordinate.latitude;
        if (currentLocation.coordinate.longitude > maxLon)
            maxLon = currentLocation.coordinate.longitude;
        if (currentLocation.coordinate.latitude < minLat)
            minLat = currentLocation.coordinate.latitude;
        if (currentLocation.coordinate.longitude < minLon)
            minLon = currentLocation.coordinate.longitude;
    }
    
    MKCoordinateRegion region;
    region.center.latitude = (maxLat + minLat) / 2;
    region.center.longitude = (maxLon + minLon) / 2;
    region.span.latitudeDelta = maxLat - minLat;
    region.span.longitudeDelta = maxLon - minLon;
    
    return region;
}

//
// * * * * * * * * * * * * * * * * * * * * * *
//
- (MKMapRect) updateMapRect
{
    double minX;
    double minY;
    double maxX;
    double maxY;
    
    MKMapPoint* pointArr = malloc(sizeof(CLLocationCoordinate2D) * [ptTrack count]);
    
    if ([ptTrack count] < 2) {
        return ptMapRect;
    }
    
    if (MKMapRectIsEmpty(ptMapRect)) {
        //
        NSLog(@"Ha! ptMapRect is empty");
    }
    
    TOMPointOnAMap *p = [ptTrack objectAtIndex:0];
    MKMapPoint newPoint = MKMapPointForCoordinate([p coordinate]);
    maxX = minX = newPoint.x;
    maxY = minY = newPoint.y;
    pointArr[0] = newPoint;
    for (int i = 1; i < [ptTrack count]; i++ )
    {
        p = [ptTrack objectAtIndex:i];
        // CLLocation *currentLocation = [p location];
        newPoint = MKMapPointForCoordinate([p coordinate]);
        
        minX = MIN(minX, newPoint.x);
        minY = MIN(minY, newPoint.y);
        maxX = MAX(maxX, newPoint.x);
        maxY = MAX(maxY, newPoint.y);
        pointArr[i] = newPoint;
    }
    
    // self.routeLine = [ MKPolyline polylineWithPoints:pointArr count:[pebbleTrack count]];
    ptMapRect = MKMapRectMake(minX, minY, (maxX-minX), (maxY-minY));
    return ptMapRect;
    
}
//
// * * * * * * * * * * * * * * * * * * * * * *
//
- (NSString *) elapseTimeString {
    NSString *myTimeString = NULL;
    
    NSTimeInterval mytime = [self elapseTime];
    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    
    if (mytime > 3600.00) {
        hours = mytime / 3600;
        mytime -= (hours * 3600);
    }
    
    if (mytime > 60.00) {
        minutes = mytime / 60;
        mytime -= (minutes * 60);
    }
    seconds = mytime;
    
    if  (hours > 0 )
        myTimeString = [[NSString alloc] initWithFormat:@"%0d:%02d:%02d",hours,minutes,seconds];
    else if (minutes > 0 )
        myTimeString = [[NSString alloc] initWithFormat:@"%0d:%02d",minutes,seconds];
    else
        myTimeString = [[NSString alloc] initWithFormat:@"%d",seconds];
    
    // NSLog(@"%s %@",__func__, myTimeString);
    return myTimeString;
}
//
// * * * * * * * * * * * * * * * * * * * * * *
//
- (NSTimeInterval) elapseTime {
    
    NSDate  *mystart = NULL;
    NSDate  *myend = NULL;
    
    // [self listPoms];
    
    // NSTimeInterval i;
    for (int i = 0 ; i < [ptTrack count]; i++ ) {
        TOMPointOnAMap *p = [ptTrack objectAtIndex:i];
        if (!mystart) {
            mystart = p.timestamp;
            myend = p.timestamp;
        }
        else {
            
            // NSLog(@"Start:%@",mystart);
            // NSLog(@"  End:%@",myend);
            // NSLog(@"    P:%@",p.timestamp);
            // NSLog(@"Interval S:%f", [mystart timeIntervalSinceDate:p.timestamp ]);
            // NSLog(@"Interval E:%f", [myend timeIntervalSinceDate:p.timestamp]);
            
            mystart = [mystart earlierDate:p.timestamp];
            myend = [myend laterDate:p.timestamp];
        }
    }
    
    // NSLog(@"Start:%@",mystart);
    // NSLog(@"  End:%@",myend);
    return [myend timeIntervalSinceDate:mystart];
}


// * * * * * * * * *

- (NSInteger) numPics
{
    NSInteger count = 0;
    for (int i = 0 ; i < [ptTrack count]; i++ ) {
        TOMPointOnAMap *p = [ptTrack objectAtIndex:i];
        if ([p type] == ptPicture)
            count++;
    }
    return count;
}



@end
