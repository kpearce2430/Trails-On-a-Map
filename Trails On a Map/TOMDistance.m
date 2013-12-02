//
//  TOMDistance.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 11/30/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import "TOMDistance.h"

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
            return d/10000.000f;
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

@end
