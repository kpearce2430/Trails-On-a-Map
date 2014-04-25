//
//  TOMPropertyViewController.h
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/19/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOMProperties.h"
#import "TOMPointOnAMap.h"

#import <math.h>

@interface TOMPropertyViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate, UIActionSheetDelegate>
{
    @private
    // UIDeviceOrientation currentDeviceOrientation;
    UIInterfaceOrientation currentInterfaceOrientation;
}

// Controller sub-views
@property (nonatomic, readwrite) UIScrollView *scrollView;

// The title type
@property (nonatomic, readwrite) UILabel *titleLabel;
@property (nonatomic,readwrite) UITextField *titleField;
//
// The map type
@property (nonatomic, readwrite) UILabel *mapTypeLabel;
@property (nonatomic, readwrite) UISegmentedControl *mapTypeSegmentedControl;

// The user tracking
@property (nonatomic, readwrite) UILabel *userTrackingLabel;
@property (nonatomic, readwrite) UISegmentedControl *userTrackingSegmentedControl;

// The Display Speed Units
@property (nonatomic, readwrite) UILabel *displaySpeedLabel;
@property (nonatomic, readwrite) UISegmentedControl *displaySpeedSegmentedControl;

// The Display Distance Units
@property (nonatomic, readwrite) UILabel *displayDistanceLabel;
@property (nonatomic, readwrite) UISegmentedControl *displayDistanceSegmentedControl;

// Distance Filter Silder
@property (nonatomic, readwrite ) UILabel *distanceFilterLabel;
@property (nonatomic, readwrite) UISlider *distanceFilterSliderCtl;

// Accuracy Filter
@property (nonatomic, readwrite) UILabel *accuracyFilterLabel;
@property (nonatomic, readwrite) UISegmentedControl *accuracyFilterSegmentedControl;

// The Toggles:
@property (nonatomic, readwrite) UILabel *toggleLabel;

// Location
@property (nonatomic, readwrite) UILabel *locationLabel;
@property (nonatomic, readwrite) UISwitch *locationSwitch;

// Pictures
@property (nonatomic, readwrite) UILabel *pictureLabel;
@property (nonatomic, readwrite) UISwitch *pictureSwitch;

// Stops
@property (nonatomic, readwrite) UILabel *stopLabel;
@property (nonatomic, readwrite) UISwitch *stopSwitch;

// Odometer
@property (nonatomic, readwrite) UILabel *odoMeterLabel;
@property (nonatomic, readwrite) UISwitch *odoMeterSwitch;

// Trip Meter
@property (nonatomic, readwrite) UILabel *tripMeterLabel;
@property (nonatomic, readwrite) UISwitch *tripMeterSwitch;

// Slider (histograph)
@property (nonatomic, readwrite) UILabel *sliderLabel;
@property (nonatomic, readwrite) UISwitch *sliderSwitch;

@property (nonatomic, readwrite) UILabel *speedOMeterLabel;
@property (nonatomic, readwrite) UISwitch *speedOMeterSwitch;


// Properties Sync Switch
@property (nonatomic, readwrite) UILabel *syncLabel;
@property (nonatomic, readwrite) UISwitch *syncSwitch;

@property (nonatomic, readwrite) UILabel *iCloudLabel;
@property (nonatomic, readwrite) UISwitch *iCloudSwitch;

@property (nonatomic, readwrite) UIButton *resetButton;

@property (nonatomic, readwrite) UILabel *versionLabel;

- (BOOL) textFieldShouldReturn:(UITextField *)textField;
- (void) createControls;
+ (UILabel *)labelWithFrame:(CGRect)frame title:(NSString *)title;
- (void)orientationPropertiesChanged:(NSNotification *)notification;
- (void)resetTOM:(UIButton*)button;

@end
