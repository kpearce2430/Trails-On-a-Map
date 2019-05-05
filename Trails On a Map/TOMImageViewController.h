//
//  TOMImageViewController.h
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 3/16/14.
//  Copyright (c) 2014 Pearce Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOMPointOnAMap.h"
#import "TOMImageStore.h"
#import "TOMUIUtilities.h"

// #ifdef USE_AVIARY
//
// #import <AviarySDK/AviarySDK.h>

// #define kAviaryAPIKey "003c2565b9dc1470"
// #define kAviarySecret "0a77f0f9ae9cc6e4"


// #define CLIENT_SECRET "89029c16-a5bc-486a-b4b8-1133495f9973"
// #define CLIENT_ID_DEVELOPMENT_MODE "fd4ab65967484ac4826cb9efc5398b09"

// @interface TOMImageViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate, UIActionSheetDelegate, AFPhotoEditorControllerDelegate >
// #else
@interface TOMImageViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate, UIActionSheetDelegate >
// #endif

{
    @private
    UIInterfaceOrientation currentInterfaceOrientation;
    IBOutlet UIScrollView *imageScrollView;
    IBOutlet UIImageView  *imageView;
    UIImage *image;
    NSString *trailName;
    UIBarButtonItem *editAndDoneButton;
}

@property (nonatomic, readwrite) NSURL *url;      // URL to the Image File
@property (nonatomic, readonly)  TOMPointOnAMap *mp;

- (id)initWithNibNameAndPom:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil Trail: (NSString *) t POM: (TOMPointOnAMap *) p url:(NSURL *)u;
- (void)view:(UIView*)view setCenter:(CGPoint)centerPoint;

@end
