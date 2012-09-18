//
//  HTActivityIndicator.m
//  HotelTonight
//
//  Created by Andy Lin on 8/21/12.
//  Copyright (c) 2012 Hotel Tonight. All rights reserved.
//

#import "HTActivityIndicator.h"
#import <QuartzCore/QuartzCore.h>

@interface HTActivityIndicator ()
@property (nonatomic, retain) UIImageView *indicatorImage;
@property (nonatomic, assign) BOOL isAnimating;
@end

@implementation HTActivityIndicator

- (id)initWithIndicatorStyle:(HTActivityIndicatorStyle)style
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        float size;
        switch (style) {
            case HTActivityIndicatorStyleLargeWhite:
                size = 32.0;
                break;
            case HTActivityIndicatorStyleMediumWhite:
                size = 22.0;
                break;
            case HTActivityIndicatorStyleSmallWhite:
                size = 16.0;
                break;
            default:
                size = 20.0;
                break;
        }
        
        self.frame = CGRectMake(0.0, 0.0, size, size);
        
        _indicatorImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_white"]];
        _indicatorImage.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        _indicatorImage.frame = self.bounds;
        _indicatorImage.alpha = 0.5;
        [self addSubview:_indicatorImage];
        
        _isAnimating = NO;
        _hidesWhenStopped = YES;
        self.hidden = YES;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Accessors

- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped
{
    _hidesWhenStopped = hidesWhenStopped;
    if (!_isAnimating) {
        self.hidden = _hidesWhenStopped;
    }
}

#pragma mark - Public

- (void)startAnimating
{
    if (_isAnimating) {
        return;
    }
    
    _isAnimating = YES;
    self.hidden = NO;

    float duration = 1.5;
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    rotationAnimation.duration = duration;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.removedOnCompletion = NO; // Need this or the animation will stop if it goes off screen
    [_indicatorImage.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopAnimating
{
    _isAnimating = NO;
    [_indicatorImage.layer removeAllAnimations];
    if (_hidesWhenStopped) {
        self.hidden = YES;
    }
}

@end
