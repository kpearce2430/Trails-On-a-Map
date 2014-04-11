//
//  TOMPointOnAMap.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/18/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import "TOMPointOnAMap.h"
#import "TOMImageStore.h"

@implementation TOMPointOnAMap

@synthesize altitude, coordinate, heading, horizontal, image, key, speed, subtitle, title, timestamp, type, vertical,isTrailIcon;

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
        [self setImage:nil];
        CLLocationSpeed mySpeed = [TOMSpeed displaySpeed:speed];
        title = [NSString stringWithFormat:@"%@: %.4f %.4f %.2f%@", @POM_TYPE_LOCATION, self.coordinate.latitude, self.coordinate.longitude, mySpeed,[TOMSpeed displaySpeedUnits]];
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
        [self generateMyKey:0];
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
        [self setImage:nil];
        
        CLLocationSpeed mySpeed = [TOMSpeed displaySpeed:speed];
        title = [NSString stringWithFormat:@"%@: %.4f %.4f %.2f%@", @POM_TYPE_LOCATION, self.coordinate.latitude, self.coordinate.longitude, mySpeed,[TOMSpeed displaySpeedUnits]];
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
        [self setImage:nil];
    
        CLLocationSpeed mySpeed = [TOMSpeed displaySpeed:speed];
        switch (pt) {
            case ptError:
                title = [NSString stringWithFormat:@"%@: %.4f %.4f %.2f%@", @POM_TYPE_ERR, self.coordinate.latitude, self.coordinate.longitude, mySpeed,[TOMSpeed displaySpeedUnits]];
                break;
            case ptUnknown:
                title = [NSString stringWithFormat:@"%@: %.4f %.4f %.2f%@", @POM_TYPE_UNKNOWN, self.coordinate.latitude, self.coordinate.longitude, mySpeed,[TOMSpeed displaySpeedUnits]];
                break;
            case ptLocation:
                title = [NSString stringWithFormat:@"%@: %.4f %.4f %.2f%@", @POM_TYPE_LOCATION, self.coordinate.latitude, self.coordinate.longitude, mySpeed,[TOMSpeed displaySpeedUnits]];
                break;
            case ptPicture:
                title = [NSString stringWithFormat:@"%@: %.4f %.4f",        @POM_TYPE_PICTURE, self.coordinate.latitude, self.coordinate.longitude];
                break;
            case ptStop:
                title = [NSString stringWithFormat:@"%@: %.4f %.4f",        @POM_TYPE_STOP, self.coordinate.latitude, self.coordinate.longitude];
                break;
            default:
                title = [NSString stringWithFormat:@"%@: %.4f %.4f %.2f%@", @POM_TYPE_OTHER, self.coordinate.latitude, self.coordinate.longitude, mySpeed,[TOMSpeed displaySpeedUnits]];
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
        
        CLLocation *myloc = [[CLLocation alloc] initWithCoordinate:[self coordinate]
                                                          altitude:[self altitude]
                                                horizontalAccuracy:[self horizontal]
                                                  verticalAccuracy:[self vertical]
                                                         timestamp:[self timestamp]];
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
    
    image = nil;
    [aCoder encodeObject:image forKey:@"image"];
    
    // NSString tmp;
    // if (isTrailIcon)
    //     [aCoder encodeObject:@YES_STRING forKey:@"isTrailIcon"];
    // else
    //    [aCoder encodeObject:@NO_STRING forKey:@"isTrailIcon"];
}

-(id) initWithCoder:(NSCoder *) aDecoder
{
    double mylat,mylong;
    NSInteger myType;

    
    // NSString *myYN;

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

#ifdef __FFU__
        UIImage *myImage = [aDecoder decodeObjectForKey:@"image"];
        
        // to take images out of the core data trail
        if (image) {
            [TOMImageStore saveImage:myImage title:title key:key];
            image = nil;
        }
#endif
    }
    return self;
}

- (NSString *) pomCSV
{
    // @"Type,Title,Altitude,Heading,Date,Time,Horizontal,Vertical,Latitude,Longitude";
    static NSDateFormatter *dateFormatter = nil;
    static NSDateFormatter *timeFormatter = nil;
    NSArray *typeStrs = [NSArray arrayWithObjects:@"Unknown",@"Location",@"Picture",@"Stop",@"Note",@"Sound",nil];
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    }
    
    if (!timeFormatter) {
        timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"HH:mm:ss"];
    }
    
    NSString *dateStr = [dateFormatter stringFromDate:timestamp];
    NSString *timeStr = [timeFormatter stringFromDate:timestamp];
    
    NSString *theString = [[NSString alloc] initWithFormat:@"%@,%@,%.2f,%.2f,%@,%@,%.2f,%.2f,%.2f,%.8f,%.8f",
                           typeStrs[type],title,altitude,[heading trueHeading],dateStr,timeStr,[TOMSpeed displaySpeed:speed],horizontal,vertical,coordinate.latitude,coordinate.longitude];
    
    return theString;
}

@end
