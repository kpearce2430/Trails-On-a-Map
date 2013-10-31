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

@interface TOMPropertyViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>

@property (nonatomic,readwrite) UITextField *titleField;
//
//  These two items are here to keep a field avaiable to
//  Update between the controller and controlee
//
@property (nonatomic, readwrite ) UILabel *distanceFilterLabel;
@property (nonatomic, readwrite ) UILabel *accuracyFilterLabel;

- (BOOL) textFieldShouldReturn:(UITextField *)textField;
- (void) createControls;
+ (UILabel *)labelWithFrame:(CGRect)frame title:(NSString *)title;

@end
