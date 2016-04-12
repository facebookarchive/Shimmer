/**
  Copyright (c) 2014-present, Facebook, Inc.
  All rights reserved.

  This source code is licensed under the BSD-style license found in the
  LICENSE file in the root directory of this source tree. An additional grant
  of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ViewController.h"

#import <FBShimmering/FBShimmeringView.h>

@interface ViewController ()

@end

@implementation ViewController
{
  UIImageView *_wallpaperView;
  FBShimmeringView *_shimmeringView;
  UILabel *_logoLabel;
  
  UILabel *_valueLabel;
  
  CGFloat _panStartValue;
  BOOL _panVertical;
}

- (BOOL)prefersStatusBarHidden
{
  return YES;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor blackColor];
  
  _wallpaperView = [[UIImageView alloc] initWithFrame:self.view.bounds];
  _wallpaperView.image = [UIImage imageNamed:@"Wallpaper"];
  _wallpaperView.contentMode = UIViewContentModeScaleAspectFill;
  [self.view addSubview:_wallpaperView];
  
  CGRect valueFrame = self.view.bounds;
  valueFrame.size.height = valueFrame.size.height * 0.25;
  
  _valueLabel = [[UILabel alloc] initWithFrame:valueFrame];
  _valueLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:32.0];
  _valueLabel.textColor = [UIColor whiteColor];
  _valueLabel.textAlignment = NSTextAlignmentCenter;
  _valueLabel.numberOfLines = 0;
  _valueLabel.alpha = 0.0;
  _valueLabel.backgroundColor = [UIColor clearColor];
  [self.view addSubview:_valueLabel];
  
  _shimmeringView = [[FBShimmeringView alloc] init];
  _shimmeringView.shimmering = YES;
  _shimmeringView.shimmeringBeginFadeDuration = 0.3;
  _shimmeringView.shimmeringOpacity = 0.3;
  [self.view addSubview:_shimmeringView];
  
  _logoLabel = [[UILabel alloc] initWithFrame:_shimmeringView.bounds];
  _logoLabel.text = @"Shimmer";
  _logoLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:60.0];
  _logoLabel.textColor = [UIColor whiteColor];
  _logoLabel.textAlignment = NSTextAlignmentCenter;
  _logoLabel.backgroundColor = [UIColor clearColor];
  _shimmeringView.contentView = _logoLabel;
  
  UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapped:)];
  [self.view addGestureRecognizer:tapRecognizer];
  
  UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panned:)];
  [self.view addGestureRecognizer:panRecognizer];
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];

  CGRect shimmeringFrame = self.view.bounds;
  shimmeringFrame.origin.y = shimmeringFrame.size.height * 0.68;
  shimmeringFrame.size.height = shimmeringFrame.size.height * 0.32;
  _shimmeringView.frame = shimmeringFrame;
}

- (void)_tapped:(UITapGestureRecognizer *)tapRecognizer
{
  _shimmeringView.shimmering = !_shimmeringView.shimmering;
}

- (void)_panned:(UIPanGestureRecognizer *)panRecognizer
{
  CGPoint translation = [panRecognizer translationInView:self.view];
  CGPoint velocity = [panRecognizer velocityInView:self.view];
  
  if (panRecognizer.state == UIGestureRecognizerStateBegan) {
#if CGFLOAT_IS_DOUBLE
    _panVertical = (fabs(velocity.y) > fabs(velocity.x));
#else
    _panVertical = (fabsf(velocity.y) > fabsf(velocity.x));
#endif
    
    if (_panVertical) {
      _panStartValue = _shimmeringView.shimmeringSpeed;
    } else {
      _panStartValue = _shimmeringView.shimmeringOpacity;
    }
    
    [self _animateValueLabelVisible:YES];
  } else if (panRecognizer.state == UIGestureRecognizerStateChanged) {
    CGFloat directional = (_panVertical ? translation.y : translation.x);
    CGFloat possible = (_panVertical ? self.view.bounds.size.height : self.view.bounds.size.width);
    
    CGFloat progress = (directional / possible);
    
    if (_panVertical) {
      _shimmeringView.shimmeringSpeed = fmaxf(0.0, fminf(1000.0, _panStartValue + progress * 200.0));
      _valueLabel.text = [NSString stringWithFormat:@"Speed\n%.1f", _shimmeringView.shimmeringSpeed];
    } else {
      _shimmeringView.shimmeringOpacity = fmaxf(0.0, fminf(1.0, _panStartValue + progress * 0.5));
      _valueLabel.text = [NSString stringWithFormat:@"Opacity\n%.2f", _shimmeringView.shimmeringOpacity];
    }
  } else if (panRecognizer.state == UIGestureRecognizerStateEnded ||
             panRecognizer.state == UIGestureRecognizerStateCancelled) {
    [self _animateValueLabelVisible:NO];
  }
}

- (void)_animateValueLabelVisible:(BOOL)visible
{
  UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
  void (^animations)() = ^{
    _valueLabel.alpha = (visible ? 1.0 : 0.0);
  };
  [UIView animateWithDuration:0.5 delay:0.0 options:options animations:animations completion:NULL];
}

@end
