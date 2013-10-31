//
//  TOMRootViewController.h
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/15/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "TOM.h"
#import "TOMPomSet.h"
#import "TOMMapSet.h"
#import "TOMProperties.h"
#import "TOMTrackView.h"
#import "TOMImageStore.h"

@interface TOMRootViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate >

{
@private
    CLLocationManager *locationManager;
    IBOutlet MKMapView *worldView;
    
@public
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UILabel *speedBar;
    IBOutlet UILabel *infoBar;
    NSTimer *ptTimer;
    
    TOMTrackView  *trailView;
    TOMMapSet     *mapPoms;
    TOMImageStore *imageStore;
}

// These would be the current properties
@property (nonatomic, strong)    CLLocationManager  *locationManager;
@property (nonatomic, strong)    IBOutlet MKMapView *worldView;

@property (nonatomic, strong) TOMProperties *myProperties;
@property (nonatomic, strong) TOMPomSet     *theTrail;

@property (nonatomic, readwrite) BOOL amiUpdatingLocation;

@property (nonatomic, readwrite) CLHeading *currentHeading;
@property (nonatomic, readwrite) BOOL hidden;

// Methods:
- (void)updateCloudItems:(NSNotification *)notification;
- (IBAction)propertiesView:(id)sender;
- (IBAction)startStop:(id)sender;
- (IBAction)takePicture:(id)sender;
- (IBAction)organizeTrails:(id)sender;
- (void) processMyLocation:(CLLocation *)newLocation type: (POMType) pt;
- (BOOL) loadPoms:(NSString *) title;
- (BOOL) savePoms:(NSString *) title;

@end
