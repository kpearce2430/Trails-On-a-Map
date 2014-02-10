//
//  TOMPointOnAMap.h
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/18/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "TOM.h"
#import "TOMSpeed.h"

// Optional
//  - Pic
//  - Movie
//  - Note / URL
//  - Sound

typedef enum  { ptError = -1, ptUnknown, ptLocation, ptPicture, ptStop, ptNote, ptSound } POMType;

@interface TOMPointOnAMap : NSObject

// This is a required property from MKAnnotation
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
//
// This is an optional property for MKAnnotation
// by specifiying  non atomic, the use of a lock is avoided.
//
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) UIImage *image; // thumb nail for annotation

@property (nonatomic, readwrite) POMType type;
//
// These are other properties used throught pt
//
@property (nonatomic, readwrite) CLLocationDistance altitude;
@property (nonatomic, copy) CLHeading *heading;
@property (nonatomic, readwrite) CLLocationSpeed speed;
@property (nonatomic, copy)  NSDate *timestamp;
@property (nonatomic, readwrite)  CLLocationAccuracy horizontal;
@property (nonatomic, readwrite)  CLLocationAccuracy vertical;
//
// Methods
//
- (id) initWithLocation:(CLLocation *)loc;
- (id) initWithLocationHeading:(CLLocation *)loc heading:(CLHeading *) hdng;
- (id) initWithLocationHeadingType:(CLLocation *)loc heading:(CLHeading *)hdng type:(POMType)pt;
- (id) initWithImage: (UIImage*)image location:(CLLocation *)loc heading:(CLHeading *) hdng;

- (void) copyLocation:(CLLocation *) loc;
- (double) distanceFromLocation:(CLLocation *)loc;
- (CLLocation *) location;

@end
