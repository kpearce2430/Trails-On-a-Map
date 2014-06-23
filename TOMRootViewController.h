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
#import "TOMViewSlider.h"
#import "TOMSpeedOMeter.h"
#import "TOMOdometer.h"
#import "TOMTripTimer.h"
#import "TOMMapAnnotation.h"
// #import "TOMMapAnnotationView.h"

@interface TOMRootViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>

{
@private
    CLLocationManager *locationManager;
    // IBOutlet MKMapView *worldView;
    UIToolbar        *toolbar;
    TOMViewSlider    *mySlider;
    TOMSpeedOMeter   *mySpeedOMeter;
    TOMOdometer      *myOdoMeter;
    TOMTripTimer     *myTripTimer;
    TOMMapAnnotation *myAnnotation;
    TOMPointOnAMap   *myPoint;
    
@public

    UIBarButtonItem *flexItem;
    UIBarButtonItem *cameraItem;
    UIBarButtonItem *startStopItem;
    UIBarButtonItem *organizerItem;

    NSTimer *ptTimer;
    
    TOMTrackView  *trailView;
    TOMMapSet     *mapPoms;
}

// These would be the current properties
@property (nonatomic, strong)    CLLocationManager  *locationManager;
@property (nonatomic, readwrite) CLHeading *currentHeading;
@property (nonatomic, strong)    IBOutlet MKMapView *worldView;

@property (nonatomic, strong)    TOMProperties *myProperties;
@property (nonatomic, strong)    TOMPomSet     *theTrail;

@property (nonatomic, readwrite) BOOL amiUpdatingLocation;
@property (nonatomic, readwrite) BOOL hidden;
@property (nonatomic, readwrite) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong)    UIImagePickerController *imagePicker;

// Methods:
- (void)updateCloudItems:(NSNotification *)notification;
- (IBAction)propertiesView:(id)sender;
- (IBAction)startStop:(id)sender;
- (IBAction)takePicture:(id)sender;
- (IBAction)organizeTrails:(id)sender;

- (void) processMyLocation:(CLLocation *)newLocation type: (POMType) pt;
- (BOOL) loadTrails:(NSURL *) fileURL;
- (BOOL) saveTrails: (BOOL) yn;
- (void) launchCamera;
- (void) launchPhotoLibrary;
- (void) checkProperties;

@end
