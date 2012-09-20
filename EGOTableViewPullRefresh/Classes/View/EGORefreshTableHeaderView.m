//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGORefreshTableHeaderView.h"

#define TEXT_COLOR [UIColor whiteColor]
#define FLIP_ANIMATION_DURATION 0.18f

@interface EGORefreshTableHeaderView ()

@end

@implementation EGORefreshTableHeaderView

- (id)initWithFrame:(CGRect)frame arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor  {
    if (self = [super initWithFrame:frame]) {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
		_lastUpdatedLabel = [self createLastUpdatedLabelWithTextColor:textColor];
        _lastUpdatedLabel.frame = CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f);
        [self addSubview:_lastUpdatedLabel];
		
		_statusLabel = [self createStatusLabelWithTextColor:textColor];
        _statusLabel.frame = CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f);
        [self addSubview:_statusLabel];
		
		CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(25.0f, frame.size.height - 65.0f, 30.0f, 55.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:arrow].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
		
        _activityView = [self createActivityIndicatorView];
        _activityView.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
        [self addSubview:_activityView];
		
        self.state = EGOOPullRefreshNormal;
    }
	
    return self;
}

- (UILabel *)createLastUpdatedLabelWithTextColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.textColor = textColor;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    return label;
}

- (UILabel *)createStatusLabelWithTextColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.textColor = textColor;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    return label;
}

- (UIView *)createActivityIndicatorView
{
    UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    return view;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame arrowImageName:@"whiteArrow.png" textColor:TEXT_COLOR];
}

- (void)refreshLastUpdatedDate
{
	if ([self.delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
		NSDate *date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
		
		[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        
		_lastUpdatedLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [dateFormatter stringFromDate:date]];
		[[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	} else {
		_lastUpdatedLabel.text = nil;
	}
}

#pragma mark - Setters

- (void)setState:(EGOPullRefreshState)aState
{
	switch (aState) {
		case EGOOPullRefreshPulling:
			self.statusLabel.text = NSLocalizedString(@"Release to refresh...", @"Release to refresh status");
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			self.arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			
			break;
            
		case EGOOPullRefreshNormal:
			if (self.state == EGOOPullRefreshPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				self.arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
			self.statusLabel.text = NSLocalizedString(@"Pull down to refresh...", @"Pull down to refresh status");
            if ([self.activityView respondsToSelector:@selector(stopAnimating)]) {
                [(id)self.activityView stopAnimating];
            }
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			self.arrowImage.hidden = NO;
			self.arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			[self refreshLastUpdatedDate];
			
			break;
            
		case EGOOPullRefreshLoading:
			self.statusLabel.text = NSLocalizedString(@"Loading...", @"Loading Status");
            if ([self.activityView respondsToSelector:@selector(startAnimating)]) {
                [(id)self.activityView startAnimating];
            }
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			self.arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
            
		default:
			break;
	}
	
	_state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView
{
	if (_state == EGOOPullRefreshLoading) {
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, self.scrollViewInsets.top);
		offset = MIN(offset, 60 + self.scrollViewInsets.top);
        UIEdgeInsets insets = scrollView.contentInset;
        insets.top = offset;
		scrollView.contentInset = insets;
	} else if (scrollView.isDragging) {
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
			_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
		}
		
		if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -65.0f - self.scrollViewInsets.top && scrollView.contentOffset.y < -self.scrollViewInsets.top && !_loading) {
			[self setState:EGOOPullRefreshNormal];
		} else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -65.0f - self.scrollViewInsets.top && !_loading) {
			[self setState:EGOOPullRefreshPulling];
		}
		
		if (scrollView.contentInset.top != self.scrollViewInsets.top) {
            UIEdgeInsets insets = scrollView.contentInset;
            insets.top = self.scrollViewInsets.top;
			scrollView.contentInset = insets;
		}
	}
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView
{
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
		_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y <= - 65.0f - self.scrollViewInsets.top && !_loading) {
		
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
			[_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
		}
		
		[self setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
        UIEdgeInsets insets = scrollView.contentInset;
        insets.top = 60.0f + self.scrollViewInsets.top;
		scrollView.contentInset = insets;
		[UIView commitAnimations];
	}
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
    UIEdgeInsets insets = scrollView.contentInset;
    insets.top = self.scrollViewInsets.top;
    scrollView.contentInset = insets;
	[UIView commitAnimations];
	
	[self setState:EGOOPullRefreshNormal];
}

@end
