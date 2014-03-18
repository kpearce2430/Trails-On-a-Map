//
//  TOMImageViewController.h
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 3/16/14.
//  Copyright (c) 2014 Pearce Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TOMImageViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate, UIActionSheetDelegate>
{
    @private
    UIInterfaceOrientation currentInterfaceOrientation;
}

@property (nonatomic, readwrite) UIScrollView *scrollView;
@property (nonatomic, readwrite) UIImageView *imageView;
@property (nonatomic, readwrite) UIImage *image;
@property (nonatomic, readwrite) NSString *key;
@property (nonatomic, readwrite) NSURL *url;

- (id)initWithNibNameWithKeyAndImage:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil key:(NSString *)k url:(NSURL *)u;

@end
