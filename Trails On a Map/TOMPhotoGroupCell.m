//
//  TOMPhotoGroupCell.m
//  Trails On a Map
//
//  Created by KEITH PEARCE on 12/11/13.
//  Copyright (c) 2013 Pearce Software Solutions. All rights reserved.
//

#import "TOMPhotoGroupCell.h"

@implementation TOMPhotoGroupCell

@synthesize photoImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //we create the UIImageView in this overwritten init so that we always have it at hand.
        photoImage = [[UIImageView alloc] init];
        //set specs and special wants for the imageView here.
        [self addSubview:photoImage]; //the only place we want to do this addSubview: is here!
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //You wanted the imageView to react to touches and gestures. We can do that here too.
        UITapGestureRecognizer * tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onButtonTapped:)];
        [tap setNumberOfTapsRequired:1];
        [self addGestureRecognizer:tap];
        

        [self setNeedsDisplay]; // force drawRect:

        //We can also prepare views with additional contents here!
        //just add more labels/views/whatever you want.
    }
    return self;
}

-(void)onButtonTapped:(id)sender
{
    //the response to the gesture.
    //mind that this is done in the cell. If you don't want things to happen from this cell.
    //then you can still activate this the way you did in your question.
    NSLog(@"Who's tapping now? %@",sender);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    // NSLog(@"Photo %ld:%x",(long)self.tag, self.photoImage.image);
    [ self.photoImage.image drawAtPoint:CGPointMake(0.0, 0.0)];
}





@end
