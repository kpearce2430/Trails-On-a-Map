//
//  TOMImageViewController.m
//  Trails On a Map
//
//  Created by KEITH E PEARCE  on 3/16/14.
//  Copyright (c) 2014 Pearce Software Solutions. All rights reserved.
//

#import "TOMImageViewController.h"

@interface TOMImageViewController ()

@end

@implementation TOMImageViewController

@synthesize scrollView,imageView,image,key,url;

- (id)initWithNibNameWithKeyAndImage:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil key:(NSString *)k url:(NSURL *)u
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        key = k;
        url = u;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationPropertiesChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    if (url) {
        NSError *err = nil;
        NSData *data = [NSData dataWithContentsOfURL:url
                                             options:NSDataReadingUncached
                                               error:&err];
        
        if (err) {
            NSLog(@"ERROR %s loading image %@",__func__,err);
        }
        else {
            image = [UIImage imageWithData:data];
            [self createControls];
            [self orientationPropertiesChanged:nil];
        }
    }
}

//
//
-(void) viewDidDisappear {
    
    // Request to stop receiving accelerometer events and turn off accelerometer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createControls
{

    imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setUserInteractionEnabled:YES];
    [imageView setBackgroundColor:[UIColor clearColor]];
    [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
 
    //  A better way to do this...
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // screenRect.origin.y = 0; // take into account the nav bar.
    scrollView = [[UIScrollView alloc] initWithFrame:screenRect];
    scrollView.delegate = self;
    scrollView.showsVerticalScrollIndicator = YES;
    scrollView.showsHorizontalScrollIndicator = YES;
    [scrollView setContentOffset:CGPointMake(0.0f, 0.0f)];
    [scrollView setBounces:NO];
    [scrollView setScrollEnabled:YES];
    [scrollView setClipsToBounds:YES];
    [scrollView addSubview:imageView];
    [scrollView setBackgroundColor:[UIColor blackColor]];
    [scrollView setMaximumZoomScale:5.0];
    [scrollView setMinimumZoomScale:0.1];
    CGSize mySize = CGSizeMake(image.size.width, image.size.height);
    [scrollView setContentSize:mySize];
    
    [imageView sizeToFit];
    [self.view addSubview:scrollView];
    
    CGFloat scaleH = 1.0;
    CGFloat scaleW = 1.0;
    
    if (image.size.height > (screenRect.size.height - 44)) {
        scaleH = screenRect.size.height / image.size.height;
        if (scaleH < 0.1)
            scaleH = 0.1;
    }
    
    if (image.size.width > screenRect.size.width) {
        scaleW = screenRect.size.width / image.size.width;
        if (scaleW < 0.1)
            scaleW   = 0.1;
    }
    
    if (scaleH < 1.0 || scaleW < 1.0) {
        if (scaleH < scaleW)
            [scrollView setZoomScale:scaleH];
        else
            [scrollView setZoomScale:scaleW];
    }
    return;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollV withView:(UIView *)view atScale:(CGFloat)scale
{
    [scrollView setContentSize:CGSizeMake(scale*(image.size.width), scale*(image.size.height))];
}

- (void)orientationPropertiesChanged:(NSNotification *)notification
{
    // Respond to changes in device orientation
    // if (notification)
    //    NSLog(@"Orientation Changed! %@",notification);
    // else
    //    NSLog(@"Orientation Changed! (nil)");
    
    UIInterfaceOrientation uiOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if ((UIInterfaceOrientationIsLandscape(currentInterfaceOrientation) && UIInterfaceOrientationIsLandscape(uiOrientation)) ||
        (UIInterfaceOrientationIsPortrait(currentInterfaceOrientation) && UIInterfaceOrientationIsPortrait(uiOrientation))) {
        //still saving the current orientation ?
        currentInterfaceOrientation = uiOrientation;
        return;
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    
    if (UIInterfaceOrientationIsLandscape(uiOrientation)) {
        screenHeight = screenRect.size.width;
        screenWidth = screenRect.size.height;
    }
    
    // update the rest of the items on the screen with the now rect
    CGRect myScreenRect = CGRectMake(0, 0, screenWidth, screenHeight);
    [self.view setFrame:myScreenRect];
    
    CGRect myViewRect = CGRectMake(0, 0, screenWidth, screenHeight);
    [scrollView setFrame:myViewRect];
    
    CGSize mySize = CGSizeMake(image.size.width, image.size.height);
    [scrollView setContentSize:mySize];
    
    [imageView setFrame:myViewRect];
    [imageView sizeToFit];
    
    CGFloat scaleH = 1.0;
    CGFloat scaleW = 1.0;
    
    if (image.size.height > (screenHeight)) {
        scaleH = screenHeight / image.size.height;
        if (scaleH < 0.1)
            scaleH = 0.1;
    }
    
    if (image.size.width > screenWidth) {
        scaleW = screenWidth / image.size.width;
        if (scaleW < 0.1)
            scaleW   = 0.1;
    }
    
    if (scaleH < 1.0 || scaleW < 1.0) {
        if (scaleH < scaleW)
            [scrollView setZoomScale:scaleH];
        else
            [scrollView setZoomScale:scaleW];
    }
    return;
    
}

@end
