//
//  TOMDistance.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 11/30/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import "TOMDistance.h"

#ifndef DEG2RAD
#define DEG2RAD(degrees) (degrees * 0.01745327) // degrees * pi over 180
#endif

@implementation TOMDistance

//
// Display Distance
// tomDDUnknown, tomDDMiles, tomDDKilometers, tomDDMeters, tomDDFeet } TOMDisplayDistanceType ;
//
//  Assuming meters coming in:
+ (CLLocationDistance) displayDistance: (CLLocationDistance) d
{
    TOMDisplayDistanceType myDisplayUnits = [TOMDistance distanceType];
    
    switch (myDisplayUnits)
    { // omDSMPH, tomDSKPH, tomDSMPM, tomDSFPS
        case tomDDMiles:
            return d/1609.344;
            break;
            
        case tomDDKilometers:
            return d/1000.000f;
            break;
            
        case tomDDMeters:
            return d;
            break;
            
        case tomDDFeet:
            return d*3.28084;
            break;

        default:
            NSLog(@"ERROR: Invalid or Unknown %@",@KEY_DISTANCE_UNITS);
            break;
    }
    return -9999.99;
}

//
// Display Distance Units
//
//  Assuming meters coming in:
+ (NSString *) displayDistanceUnits
{
    TOMDisplayDistanceType myDisplayUnits = [TOMDistance distanceType];
    
    NSString *displayDistanceUnits = NULL;
    switch (myDisplayUnits)
    { // tomDSMPH, tomDSKPH, tomDSMPM, tomDSFPS
        case tomDDMiles:
            displayDistanceUnits = @"Mi";
            break;
            
        case tomDDKilometers:
            displayDistanceUnits = @"Km";
            break;
            
        case tomDDMeters:
            displayDistanceUnits = @"m";
            break;
            
        case tomDDFeet:
            displayDistanceUnits = @"f";
            break;
            
        default:
            displayDistanceUnits = @"x";
            NSLog(@"ERROR: Invalid or Unknown %@",@KEY_DISTANCE_UNITS);
            break;
    }
    
    return displayDistanceUnits;
}

//
//
+ (TOMDisplayDistanceType) distanceType
{
    TOMDisplayDistanceType myDisplayUnits;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_DISTANCE_UNITS] != nil)
    {
        myDisplayUnits =  (TOMDisplayDistanceType) [[NSUserDefaults standardUserDefaults] integerForKey:@KEY_DISTANCE_UNITS];
    }
    else
    {   //
        // we don't have a preference stored on this device,use the Tracking Mode None as default.
        //
        myDisplayUnits = tomDDMiles;  // default
    }
    return myDisplayUnits;
}

//
//
//
+ (CLLocationDistance) distanceFilter
{
    //
    // Distance Filter
    //
    CLLocationDistance myDistance;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_DISTANCE_FILTER] != nil)
        {
        myDistance = [[NSUserDefaults standardUserDefaults] floatForKey:@KEY_DISTANCE_FILTER];
        }
    else
        {
        // we don't have a preference stored on this device,
        // use the default value in this case (kCLLocationAccuracyBest)
        //
        myDistance = 50.0;
        }
    return myDistance;
}


//
// Based on:  http://answers.google.com/answers/threadview/id/326655.html
//
//
// I noticed some invalid numbers coming from the iphone where altitudes jumped.
// This function will compute the distance in 3D.
//
+ (CLLocationDistance) distanceFrom: (CLLocation *) loc1 To:(CLLocation *) loc2
{
    CGFloat lat1Rad = DEG2RAD(loc1.coordinate.latitude);
    CGFloat long1Rad = DEG2RAD(loc1.coordinate.longitude);
    CGFloat lat2Rad = DEG2RAD(loc2.coordinate.latitude);
    CGFloat long2Rad = DEG2RAD(loc2.coordinate.longitude);
    
    CGFloat p1X = ([loc1 altitude] + 6370000.0) * cos(lat1Rad) * sin(long1Rad);
    CGFloat p2X = ([loc2 altitude] + 6370000.0) * cos(lat2Rad) * sin(long2Rad);
    CGFloat deltaX = p2X - p1X;
    deltaX *= deltaX;
    
    CGFloat p1Y = ([loc1 altitude] + 6370000.0) * sin(lat1Rad);
    CGFloat p2Y = ([loc2 altitude] + 6370000.0) * sin(lat2Rad);
    CGFloat deltaY = p2Y - p1Y;
    deltaY *= deltaY;

    CGFloat p1Z = ([loc1 altitude] + 6370000.0) * cos(lat1Rad) * cos(long1Rad);
    CGFloat p2Z = ([loc2 altitude] + 6370000.0) * cos(lat2Rad) * cos(long2Rad);
    CGFloat deltaZ = p2Z - p1Z;
    deltaZ *= deltaZ;
    
    CLLocationDistance distance = deltaX + deltaY + deltaZ;
    distance = sqrt(distance);
    return distance;
}

@end
