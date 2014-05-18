//
//  TOMSpeed.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 11/30/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import "TOMSpeed.h"

@implementation TOMSpeed;

// @synthesize speed;

//
// Display Speed
//
+ (CLLocationSpeed) displaySpeed: (CLLocationSpeed) s
{
    TOMDisplaySpeedType myDisplayUnits = [TOMSpeed speedType];
    
    switch (myDisplayUnits)
    { // omDSMPH, tomDSKPH, tomDSMPM, tomDSFPS
        case tomDSMilesPerHour:
            return s*2.23694;
            break;
            
        case tomDSKmPerHour:
            return s*3.60000;
            break;
            
        case tomDSMinutesPerMile:
            return 26.8224/s;
            break;
            
        case tomDSMetersPerSecond:
            return s;
            break;
            
        default:
            NSLog(@"ERROR: Invalid or Unknown %@",@KEY_SPEED_UNITS);
            break;
    }
    return -9999.99;
}

+ (CLLocationSpeed) speedToMPS: (CLLocationSpeed) s
{

    TOMDisplaySpeedType myDisplayUnits = [TOMSpeed speedType];
    
    switch (myDisplayUnits)
    {
        case tomDSMilesPerHour:
            return s * 0.44704f;
            break;
            
        case tomDSKmPerHour:
            return s * 0.2777777777777778f;
            break;
            
        case tomDSMinutesPerMile:
            return s*0.037282272f;
            break;
            
        case tomDSMetersPerSecond:
            return s;
            break;
            
        default:
            NSLog(@"ERROR: Invalid or Unknown %@",@KEY_SPEED_UNITS);
            break;
    }
    return -9999.99;
}


//
// * * * * * * * * * * * * * * * * * * *
//

+ (NSString *) displaySpeedUnits
{
    TOMDisplaySpeedType myDisplayUnits = [TOMSpeed speedType];
    
    NSString *displaySpeedUnits = NULL;
    
    switch (myDisplayUnits)
    { // tomDSMPH, tomDSKPH, tomDSMPM, tomDSFPS
        case tomDSMilesPerHour:
            displaySpeedUnits = @"MPH";
            break;
            
        case tomDSKmPerHour:
            displaySpeedUnits = @"KPH";
            break;
            
        case tomDSMinutesPerMile:
            displaySpeedUnits = @"MpM";
            break;
            
        case tomDSMetersPerSecond:
            displaySpeedUnits = @"MpS";
            break;
            
        default:
            displaySpeedUnits = @"x";
            NSLog(@"ERROR: Invalid or Unknown %@",@KEY_DISTANCE_UNITS);
            break;
    }
    
    return displaySpeedUnits;
}

+ (TOMDisplaySpeedType) speedType
{
    TOMDisplaySpeedType myDisplayUnits;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@KEY_SPEED_UNITS] != nil)
    {
        myDisplayUnits =  (TOMDisplaySpeedType) [[NSUserDefaults standardUserDefaults] integerForKey:@KEY_SPEED_UNITS];
    }
    else
    {   //
        // we don't have a preference stored on this device,use the Tracking Mode None as default.
        //
        myDisplayUnits = tomDSKmPerHour;  // default
    }
    return myDisplayUnits;
}

+ (void) setSpeedType: (TOMDisplaySpeedType) speedUnit
{
    if (speedUnit == tomDSMilesPerHour ||
        speedUnit == tomDSKmPerHour ||
        speedUnit == tomDSMinutesPerMile ||
        speedUnit == tomDSMetersPerSecond ) {
        [[NSUserDefaults standardUserDefaults] setInteger: speedUnit forKey:@KEY_SPEED_UNITS];

        // set the new value for the cloud.  Note, I dont syncronize until I leave this for the controllers
        NSString *tmp = [[NSString alloc] initWithFormat:@"%d", speedUnit];
        NSUbiquitousKeyValueStore *kvStore = [NSUbiquitousKeyValueStore defaultStore];
        [kvStore setString:tmp forKey:@KEY_SPEED_UNITS];
    }
    else {
        NSLog(@"Invalid speed Unit: %ld",(long) speedUnit);
    }
}

@end
