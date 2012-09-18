//
//  HTActivityIndicator.h
//  HotelTonight
//
//  Created by Andy Lin on 8/21/12.
//  Copyright (c) 2012 Hotel Tonight. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    HTActivityIndicatorStyleLargeWhite,
    HTActivityIndicatorStyleMediumWhite,
    HTActivityIndicatorStyleSmallWhite
} HTActivityIndicatorStyle;

@interface HTActivityIndicator : UIView

@property (nonatomic, assign) BOOL hidesWhenStopped;
@property (nonatomic, readonly) BOOL isAnimating;

- (id)initWithIndicatorStyle:(HTActivityIndicatorStyle)style;
- (void)startAnimating;
- (void)stopAnimating;

@end
