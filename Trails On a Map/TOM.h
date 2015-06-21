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
#define KEY_SPEED_UNITS          "ptDisplaySpeed"
#define KEY_DISTANCE_UNITS       "ptDisplayDistance"
#define KEY_ODOMETER             "ptOdoMeter"
#define KEY_TRIPMETER            "ptTripMeter"
#define KEY_SLIDER               "ptSlider"
#define KEY_SPEEDOMETER          "ptSpeedOMeter"
#define KEY_PROPERTIES_SYNC      "ptPropertiesSync"     // Yes/No if properties are synced on iCloud.
#define KEY_ICLOUD               "ptICloud"
#define KEY_ICON_IMAGE           "ptIconImage"
#define KEY_TRAIL_ON             "ptTrailOM"            // Which trail is currently loaded on the RootViewController
#define KEY_PHOTO_COUNT          "ptPhotoCount"         //
#define KEY_GOOGLE_DRIVE_ENABLED "pkGDriveEnabled"      // Google Drive Enabled
#define KEY_GOOGLE_DRIVE_PATH    "pkGDrivePath"         // Google Drive Path


// Defaults
#define TRAILS_ON_A_MAP          "Trails On A Map"
#define TRAILS_DEFAULT_NAME       TRAILS_ON_A_MAP  // Used to be "Default"
#define TOM_FILE_EXT             ".tom"
#define TOM_GPX_EXT              ".gpx"
#define TOM_KML_EXT              ".kml"
#define TOM_KMZ_EXT              ".kmz"
#define TOM_JPG_EXT              ".jpg"
#define TOM_CSV_EXT              ".csv"
#define TOM_JPG_ICON_EXT         ".icon.jpg"

#define TOM_TOOL_BAR_HEIGHT      35
#define TOM_LABEL_WIDTH          200

#define YES_STRING                  "YES"
#define NO_STRING                   "NO"

// For the controllers
#define ptTopMargin                 20.0
#define ptLabelHeight               20.0
#define ptLeftMargin                20.0
#define ptLabelHeight               20.0
#define ptRightMargin               20.0
#define ptTweenMargin               5.0
#define ptTweenMarginMultiplier     1.0
#define ptSegmentedControlHeight    40.0

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
#define TOM_SLIDER_MAX_Y    150
#define TOM_SLIDER_MAX_Y_VERT   150
#define TOM_SLIDER_MAX_Y_HORZ   120
#define TOM_SLIDER_MIN_X    20
#define TOM_SLIDER_MAX_X    999
#define TOM_SLIDER_NUM_PTS  61
#define TOM_SLIDER_HALF_PTS 30
#define TOM_SLIDER_DEFAULT_Y    (TOM_TOOL_BAR_HEIGHT + TOM_SLIDER_MAX_Y)

// SpeedOMeter defines
#define TOM_SPEEDOMETER_DEFAULT_HEIGHT  200
#define TOM_SPEEDOMETER_DEFAULT_WIDTH   200
#define TOM_SPEEDOMETER_DEFAULT_Y       (TOM_SLIDER_DEFAULT_Y + TOM_SPEEDOMETER_DEFAULT_HEIGHT)


// OdoMter defines
#define TOM_ODOMETER_DEFAULT_HIEGHT     100
#define TOM_ODOMETER_DEFAULT_WIDTH      100
#define TOM_ODOMETER_DEFAULT_PORTRAIT_Y   (TOM_SPEEDOMETER_DEFAULT_Y + TOM_ODOMETER_DEFAULT_HIEGHT)
#define TOM_ODOMETER_DEFAULT_LANDSCAPE_Y  (TOM_SLIDER_DEFAULT_Y + TOM_ODOMETER_DEFAULT_HIEGHT)


#define TOM_FONT            "Helvetica-Bold"
#define TOM_PVC_EXTRA       450


#endif
