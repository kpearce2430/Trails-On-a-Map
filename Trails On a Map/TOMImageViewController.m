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

@synthesize url,mp;

- (id)initWithNibNameAndPom:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil Trail: (NSString *) t POM: (TOMPointOnAMap *) p url:(NSURL *)u
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        mp = p;
        self.title = p.title;
        trailName = [[NSString alloc] initWithString:t];
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
// #if USE_AVIARY
            editAndDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editClicked:)];
            self.navigationItem.rightBarButtonItem = editAndDoneButton;
// #endif
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated {

#ifdef __FFU__
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        NSLog(@"in %s",__PRETTY_FUNCTION__);
    }
#endif

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createControls
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //  A better way to do this...
    CGRect screenRect ; // = [[UIScreen mainScreen] bounds];
    [TOMUIUtilities screenRect:&screenRect];
    
    imageScrollView = [[UIScrollView alloc] initWithFrame:screenRect];
    imageScrollView.delegate = self;
    imageScrollView.showsVerticalScrollIndicator = YES;
    imageScrollView.showsHorizontalScrollIndicator = YES;
    [imageScrollView setContentOffset:CGPointMake(0.0f, 0.0f)];
    [imageScrollView setBounces:NO];
    [imageScrollView setScrollEnabled:YES];
    [imageScrollView setClipsToBounds:YES];
    [imageScrollView setBackgroundColor:[UIColor blackColor]];
    [imageScrollView setContentSize:image.size];
    
    imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setUserInteractionEnabled:YES];
    [imageView setBackgroundColor:[UIColor clearColor]];
    [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView sizeToFit];
    
    [imageScrollView setMaximumZoomScale:25.0];
    
    // calculate minimum scale to perfectly fit image width, and begin at that scale
    float minimumScale = [imageScrollView frame].size.width  / [imageView frame].size.width;
    [imageScrollView setMinimumZoomScale:minimumScale];
    [imageScrollView setZoomScale:minimumScale];
    
    [imageScrollView addSubview:imageView];
    [self.view addSubview:imageScrollView];

    CGPoint centerPoint = CGPointMake(CGRectGetMidX(imageScrollView.bounds),
                                      CGRectGetMidY(imageScrollView.bounds));
 
    [self view:imageView setCenter:centerPoint];
    return;
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollV withView:(UIView *)view atScale:(CGFloat)scale
{
    [imageScrollView setContentSize:CGSizeMake(scale*(image.size.width), scale*(image.size.height))];
}


- (void)orientationPropertiesChanged:(NSNotification *)notification
{
    // Respond to changes in device orientation
   
    UIInterfaceOrientation uiOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if ((UIInterfaceOrientationIsLandscape(currentInterfaceOrientation) && UIInterfaceOrientationIsLandscape(uiOrientation)) ||
        (UIInterfaceOrientationIsPortrait(currentInterfaceOrientation) && UIInterfaceOrientationIsPortrait(uiOrientation))) {
        //still saving the current orientation ?
        currentInterfaceOrientation = uiOrientation;
        return;
    }
    
    CGRect screenRect; // = [[UIScreen mainScreen] bounds];
    [TOMUIUtilities screenRect:&screenRect];
    
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    
    // update the rest of the items on the screen with the now rect
    CGRect myScreenRect = CGRectMake(0, 0, screenWidth, screenHeight);
    [imageScrollView setFrame:myScreenRect];
    [imageScrollView setContentSize:image.size];
    [imageView sizeToFit];
    return;
    
}
//
//  These functions thanks to:
//  http://iosdeveloperzone.com/2012/07/07/tutorial-all-about-images-part-2-panning-zooming-with-uiscrollview/
//  The center points need to be set for the view and the scroll view or else the image is
//  messed up.
//
- (void)view:(UIView*)view setCenter:(CGPoint)centerPoint
{
    CGRect vf = view.frame;
    CGPoint co = imageScrollView.contentOffset;
    
    CGFloat x = centerPoint.x - vf.size.width / 2.0;
    CGFloat y = centerPoint.y - vf.size.height / 2.0;
    
    if(x < 0)
    {
        co.x = -x;
        vf.origin.x = 0.0;
    }
    else
    {
        vf.origin.x = x;
    }
    if(y < 0)
    {
        co.y = -y;
        vf.origin.y = 0.0;
    }
    else
    {
        vf.origin.y = y;
    }
    
    view.frame = vf;
    imageScrollView.contentOffset = co;
}

- (void)scrollViewDidZoom:(UIScrollView *)sv
{
    UIView* zoomView = [sv.delegate viewForZoomingInScrollView:sv];
    CGRect zvf = zoomView.frame;
    if(zvf.size.width < sv.bounds.size.width)
    {
        zvf.origin.x = (sv.bounds.size.width - zvf.size.width) / 2.0;
    }
    else
    {
        zvf.origin.x = 0.0;
    }
    if(zvf.size.height < sv.bounds.size.height)
    {
        zvf.origin.y = (sv.bounds.size.height - zvf.size.height) / 2.0;
    }
    else
    {
        zvf.origin.y = 0.0;
    }
    zoomView.frame = zvf;
}


// #if USE_AVIARY
- (IBAction)editClicked:(id)sender {
    
    // kAviaryAPIKey and kAviarySecret are developer defined
    // and contain your API key and secret respectively
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AFPhotoEditorController setAPIKey:@kAviaryAPIKey secret:@kAviarySecret];
    });
    
    AFPhotoEditorController *editorController = [[AFPhotoEditorController alloc] initWithImage:image];
    [editorController setDelegate:self];
    [self presentViewController:editorController animated:YES completion:nil];

}

- (void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)returnImage
{
    // Handle the result image here
    NSLog(@"Done Editing");
    // image = returnImage;
    [TOMImageStore saveImage:returnImage title:trailName key:[mp key]];
    [imageView setImage:returnImage];
    [imageView sizeToFit];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
    // Handle cancellation here
    NSLog(@"Cancel Editing");
    [self dismissViewControllerAnimated:YES completion:nil];
}
// #endif

@end
