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

@interface TOMPomSet : NSObject


@property (nonatomic, strong) NSMutableArray *ptTrack;

@property (nonatomic, readwrite) MKMapRect ptMapRect;

- (id)initWithTitle: (NSString *) t;
- (void)addPointOnMap:(TOMPointOnAMap *) p;

- (void)listPoms;
- (NSString *) tomArchivePath;
- (NSString *) tomArchivePathWithTitle: (NSString *)title;
- (BOOL) savePoms:(NSString *)title;
- (BOOL) loadPoms:(NSString *)title;
- (BOOL) deletePoms:(NSString *) title;
- (BOOL) areTherePoms;
- (double) distanceTotalMeters;
- (double) distanceStraightLine;

- (MKCoordinateRegion) ptMakeRegion;
- (MKMapRect) updateMapRect;
- (TOMPointOnAMap *)lastPom;

- (NSTimeInterval) elapseTime;
- (NSString *) elapseTimeString;


@end
