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

@interface TOMRootViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate >

{
@private
    CLLocationManager *locationManager;
    // IBOutlet MKMapView *worldView;
    UIToolbar      *toolbar;
    TOMViewSlider  *mySlider;
    TOMSpeedOMeter *mySpeedOMeter;
    TOMOdometer    *myOdoMeter;
    TOMTripTimer   *myTripTimer;

@public
    IBOutlet UIActivityIndicatorView *activityIndicator;
    // IBOutlet UILabel *speedTimeBar;
    // IBOutlet UILabel *distanceInfoBar;
    UIBarButtonItem *flexItem;
    UIBarButtonItem *cameraItem;
    UIBarButtonItem *startStopItem;
    UIBarButtonItem *organizerItem;
    
    NSTimer *ptTimer;
    
    TOMTrackView  *trailView;
    TOMMapSet     *mapPoms;
    // TOMImageStore *imageStore;
}

// These would be the current properties
@property (nonatomic, strong)    CLLocationManager  *locationManager;
@property (nonatomic, readwrite) CLHeading *currentHeading;
@property (nonatomic, strong)    IBOutlet MKMapView *worldView;

@property (nonatomic, strong)    TOMProperties *myProperties;
@property (nonatomic, strong)    TOMPomSet     *theTrail;

@property (nonatomic, readwrite) BOOL amiUpdatingLocation;
@property (nonatomic, readwrite) BOOL hidden;
@property (nonatomic, readwrite) BOOL amiDeffered;

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
- (BOOL) saveTrailAs: (NSString *) title warn:(BOOL)yn;
- (void) launchCamera;
- (void) launchPhotoLibrary;
- (void) checkProperties;

@end
