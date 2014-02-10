//
//  TOM.h
//  Trails On a Map
//
//  Created by KEITH PEARCE on 10/15/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#ifndef Trails_On_a_Map_TOM_h
#define Trails_On_a_Map_TOM_h

typedef enum  { tomDSError = -1, tomDSUnknown, tomDSMilesPerHour, tomDSKmPerHour, tomDSMinutesPerMile, tomDSMetersPerSecond } TOMDisplaySpeedType;
typedef enum  { tomDDError = -1, tomDDUnknown, tomDDMiles, tomDDKilometers, tomDDMeters, tomDDFeet } TOMDisplayDistanceType ;

#define KEY_NAME                 "ptName"
#define KEY_MAP_TYPE             "ptMapType"
#define KEY_USER_TRACKING_MODE   "ptUserTrackingMode"
#define KEY_LOCATION_ACCURACY    "ptLocationAccuracy"
#define KEY_DISTANCE_FILTER      "ptDistanceFilter"
#define KEY_SHOW_LOCATIONS       "ptShowLocations"
#define KEY_SHOW_PICTURES        "ptShowPictures"
#define KEY_SHOW_STOPS           "ptShowStops"
#define KEY_SHOW_NOTES           "ptShowNotes"
#define KEY_SHOW_SOUNDS          "ptShowSounds"
#define KEY_SHOW_SPEED_LABEL     "ptShowSpeedLabel"
#define KEY_SHOW_INFO_LABEL      "ptShowInfoLabel"
#define KEY_SPEED_UNITS          "ptDisplaySpeed"
#define KEY_DISTANCE_UNITS       "ptDisplayDistance"
#define KEY_PROPERTIES_SYNC      "ptPropertiesSync"  // Yes/No if properties are synced on iCloud.

// Defaults
#define TRAILS_ON_A_MAP             "Trails On A Map"
#define TRAILS_DEFAULT_NAME       TRAILS_ON_A_MAP  // Used to be "Default"
#define TOM_FILE_EXT                 ".tom"
#define TOM_TOOL_BAR_HEIGHT          30
#define TOM_LABEL_WIDTH             200

// For the controllers
#define ptTopMargin                 20.0
#define ptLabelHeight               20.0
#define ptLeftMargin                20.0
#define ptLabelHeight               20.0
#define ptRightMargin               20.0
#define ptTweenMargin               5.0
#define ptTweenMarginMultiplier     1.0
#define ptSegmentedControlHeight    40.0

#ifdef __NUA__

#define kSegmentedControlHeight 40.0
#define kLeftMargin				20.0
#define kTopMargin				20.0

// #define kRightMarkietMultiplier 2.0
#define kTweenMargin			5.0
#define kTweenMarginMultiplier  1.0
#define kTextFieldHeight		30.0
#endif

// Other Defines
#define INITIAL_POINT_SPACE             1000
#define MINIMUM_DELTA_METERS            1.0
#define MIN_POINT_DELTA                 5.0

#define TOM_LABEL_BORDER_COLOR          [UIColor blueColor].CGColor
#define TOM_LABEL_BACKGROUND_COLOR      [UIColor whiteColor]
#define TOM_LABEL_TEXT_COLOR            [UIColor colorWithRed:76.0/255.0 green:86.0/255.0 blue:108.0/255.0 alpha:1.0]
#define TOM_LABEL_BORDER_WIDTH          .5
#define TOM_LABEL_BORDER_CORNER_RADIUS 4

#define TOM_ON_TEXT                     "ON"
#define TOM_OFF_TEXT                    "OFF"

#define POM_TYPE_ERR        "ERR"
#define POM_TYPE_UNKNOWN    "UNK"
#define POM_TYPE_LOCATION   "LOC"
#define POM_TYPE_PICTURE    "PIC"
#define POM_TYPE_STOP       "STOP"
#define POM_TYPE_OTHER      "OTH"

#define INITIAL_POINT_SPACE 1000
#define MINIMUM_DELTA_METERS 1.0

//
// Slider defines
#define TOM_SLIDER_MIN_Y    20
#define TOM_SLIDER_MAX_Y    120

#define TOM_SLIDER_NUM_PTS  61
#define TOM_FONT            "Helvetica-Bold"
#define TOM_PVC_EXTRA       400

#endif
