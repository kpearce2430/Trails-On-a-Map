//
//  TOMPomSet.h
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/18/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "TOMPointOnAMap.h"
#import "TOMUrl.h"
#import "TOMImageStore.h"

@interface TOMPomSet : UIDocument
{
@private
    NSInteger countPics;
    NSInteger iconimageID;
    UIImage *iconImage;
}

@property (nonatomic, strong) NSString *title;           //
@property (nonatomic, strong) NSMutableArray *ptTrack;   //
@property (nonatomic, readwrite) MKMapRect ptMapRect;    //

// TOM PomSet Methods
- (id)initWithTitle: (NSString *) t;
- (void)addPointOnMap:(TOMPointOnAMap *) p;
- (void)listPoms;
- (BOOL) deletePoms:(NSString *) t;
- (double) distanceTotalMeters;
- (double) distanceStraightLine;

- (MKCoordinateRegion) ptMakeRegion;
- (MKMapRect) updateMapRect;
- (TOMPointOnAMap *)lastPom;

- (NSTimeInterval) elapseTime;
- (NSString *)     elapseTimeString;
- (NSInteger)      numPics;
- (double)         averageSpeed;
- (double)         averageSpeedStraightLine;
- (BOOL) trailCSVtoURL: (NSURL *) theURL;

@end


