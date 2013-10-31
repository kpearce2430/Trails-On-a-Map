//
//  TOMPointOnAMap.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/18/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import "TOMPointOnAMap.h"

@implementation TOMPointOnAMap

@synthesize altitude, coordinate, heading, horizontal, key, speed, subtitle, title, timestamp, type, vertical;

//
//
//
- (void) generateMyKey: (NSInteger) myPid
{
    //  Key format LAT:LONG:YYYYJJJ:HH:MM:SS:PID
    //  Where LAT and Long are formated format xxx.xx
    static NSInteger count = 0;
    
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyDDD:hh:mm:ss"];
    }
    
    if (myPid == 0)
        count++;
    else
        count = myPid;
    
    CLLocationCoordinate2D myCoord = [self coordinate];
    NSDate *myDate = [self timestamp];
    
    // NSLog(@"Date for locale %@: %@",
    //       [[dateFormatter locale] localeIdentifier], [dateFormatter stringFromDate:myDate]);
    
    NSString *newKey = [[NSString alloc] initWithFormat:@"%05ld:%03.2f:%03.2f:",(long)count,myCoord.latitude,myCoord.longitude];
    
    key = [newKey stringByAppendingString:[dateFormatter stringFromDate:myDate]];
    
    // NSLog(@"Key: %@",key);
}

//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
- (id) init
{
    self = [super init];
    if (self) {
        self.coordinate = CLLocationCoordinate2DMake(34.0785, -84.2832);
        self.title = @"Home";
        self.type = ptUnknown;
        [self generateMyKey:0];
    }
    return self;
}

- (void) copyLocation:(CLLocation *) loc
{
    [self setCoordinate:[loc coordinate]];
    [self setSpeed:[loc speed]];
    [self setAltitude:[loc altitude]];
    [self setTimestamp:[loc timestamp]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    subtitle = [dateFormatter stringFromDate:self.timestamp];
}

//
// Init with only the location data and set the heading to an inital 'blank'
//
- (id) initWithLocation:(CLLocation *)loc
{
    self = [super init];
    if (self)
    {
        CLHeading *h = [[CLHeading alloc] init];
        [self copyLocation:loc];
        [self setHeading:h];
        [self setType:ptLocation];
        [self generateMyKey:0];
        
        CLLocationSpeed mph = [self speed] * 2.23694;
        title = [NSString stringWithFormat:@"%@: %.4f %.4f %.2f", @POM_TYPE_LOCATION, self.coordinate.latitude, self.coordinate.longitude, mph];
        
    }
    return self;
}

-(id) initWithImage: (UIImage *) myImage location:(CLLocation *)loc heading:(CLHeading *) hdng
{
    self = [super init];
    if (self)
    {
        [self copyLocation:loc];
        [self setHeading:hdng];
        [self setType:ptPicture];
        // [self setImage:myImage];
        title = [NSString stringWithFormat:@"%@: %.4f %.4f", @POM_TYPE_PICTURE, self.coordinate.latitude, self.coordinate.longitude ];
    }
    return self;
}

//
// Init with all the information data
//
- (id) initWithLocationHeading:(CLLocation *)loc heading:(CLHeading *) hdng;
{
    self = [super init];
    if (self)
    {
        [self copyLocation:loc];
        [self setHeading:hdng];
        [self setType:ptLocation];
        [self generateMyKey:0];
        CLLocationSpeed mph = [self speed] * 2.23694;
        title = [NSString stringWithFormat:@"%@: %.4f %.4f %.2f", @POM_TYPE_LOCATION, self.coordinate.latitude, self.coordinate.longitude, mph];
    }
    return self;
}

//
// Init with all the information data
//
- (id) initWithLocationHeadingType:(CLLocation *)loc heading:(CLHeading *)hdng type:(POMType)pt
{
    // NSString *pomType = NULL;
    self = [super init];
    if (self)
    {
        [self copyLocation:loc];
        [self setHeading:hdng];
        [self setType:pt];
        CLLocationSpeed mph = [self speed] * 2.23694;
        switch (pt) {
            case ptError:
                title = [NSString stringWithFormat:@"%@: %.4f %.4f %.2f", @POM_TYPE_ERR, self.coordinate.latitude, self.coordinate.longitude, mph];
                break;
            case ptUnknown:
                title = [NSString stringWithFormat:@"%@: %.4f %.4f %.2f", @POM_TYPE_UNKNOWN, self.coordinate.latitude, self.coordinate.longitude, mph];
                break;
            case ptLocation:
                title = [NSString stringWithFormat:@"%@: %.4f %.4f %.2f", @POM_TYPE_LOCATION, self.coordinate.latitude, self.coordinate.longitude, mph];
                break;
            case ptPicture:
                title = [NSString stringWithFormat:@"%@: %.4f %.4f",      @POM_TYPE_PICTURE, self.coordinate.latitude, self.coordinate.longitude];
                break;
            case ptStop:
                title = [NSString stringWithFormat:@"%@: %.4f %.4f",      @POM_TYPE_STOP, self.coordinate.latitude, self.coordinate.longitude];
                break;
            default:
                title = [NSString stringWithFormat:@"%@: %.4f %.4f %.2f", @POM_TYPE_OTHER, self.coordinate.latitude, self.coordinate.longitude, mph];
                break;
        }
        
        
    }
    return self;
}

//
// Computes
//
- (double) distanceFromLocation :(CLLocation *)ploc
{
    // need to reconstruct my location
    CLLocation *myloc = [self location];
    
    // CLLocation *myloc = [[CLLocation alloc] initWithCoordinate:[self coordinate] altitude:[self altitude] horizontalAccuracy:[self horizontalAccuracy] verticalAccuracy:[self verticleAccuracy] timestamp:[self timestamp]];
    
    return [ploc distanceFromLocation:myloc];
}


- (CLLocation *) location
{
    if (CLLocationCoordinate2DIsValid([self coordinate]) == YES) {
        
        CLLocation *myloc = [[CLLocation alloc] initWithCoordinate:[self coordinate] altitude:[self altitude] horizontalAccuracy:[self horizontal] verticalAccuracy:[self vertical] timestamp:[self timestamp]];
        return myloc;
    }
    else
        return nil;
}

//
// These functions are needed for archiving with NSCoder
//
-(void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:key forKey:@"key"];
    [aCoder encodeObject:title forKey:@"title"];
    [aCoder encodeObject:subtitle forKey:@"subtitle"];
    [aCoder encodeInteger:type forKey:@"type"];
    [aCoder encodeDouble:coordinate.latitude forKey:@"mylat"];
    [aCoder encodeDouble:coordinate.longitude forKey:@"mylong"];
    [aCoder encodeDouble:altitude forKey:@"altitude"];
    [aCoder encodeDouble:speed forKey:@"speed"];
    [aCoder encodeObject:heading forKey:@"heading"];
    [aCoder encodeDouble:vertical forKey:@"vacc"];
    [aCoder encodeDouble:horizontal forKey:@"hacc"];
    [aCoder encodeObject:timestamp forKey:@"timestamp"];
}

-(id) initWithCoder:(NSCoder *) aDecoder
{
    double mylat,mylong;
    NSInteger myType;
    
    self = [ super init];
    
    if (self)
    {
        [self setKey:[aDecoder decodeObjectForKey:@"key" ]];
        [self setTitle:[aDecoder decodeObjectForKey:@"title"]];
        [self setSubtitle:[aDecoder decodeObjectForKey:@"subtitle"]];
        // Prior to xcode 5.0.1: [self setType:[aDecoder decodeIntegerForKey:@"type"]];
        myType = [aDecoder decodeIntegerForKey:@"type"];
        [self setType:(POMType)myType];
        mylat = [aDecoder decodeDoubleForKey:@"mylat"];
        mylong = [aDecoder decodeDoubleForKey:@"mylong"];
        altitude = [aDecoder decodeDoubleForKey:@"altitude"];
        speed = [aDecoder decodeDoubleForKey:@"speed"];
        heading = [aDecoder decodeObjectForKey:@"heading"];
        vertical = [aDecoder decodeDoubleForKey:@"vacc"];
        horizontal = [aDecoder decodeDoubleForKey:@"hacc"];
        [self setTimestamp:[aDecoder decodeObjectForKey:@"timestamp"]];
        coordinate.latitude = mylat;
        coordinate.longitude = mylong;
    }
    return self;
}


@end
