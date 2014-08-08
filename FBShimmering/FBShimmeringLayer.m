/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBShimmeringLayer.h"

#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CAGradientLayer.h>
#import <QuartzCore/CATransaction.h>

#import <UIKit/UIGeometry.h>
#import <UIKit/UIColor.h>

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Convert your project to ARC or specify the -fobjc-arc flag.
#endif

#if TARGET_IPHONE_SIMULATOR
UIKIT_EXTERN float UIAnimationDragCoefficient(void); // UIKit private drag coeffient, use judiciously
#endif

static CGFloat FBShimmeringLayerDragCoefficient(void)
{
#if TARGET_IPHONE_SIMULATOR
  return UIAnimationDragCoefficient();
#else
  return 1.0;
#endif
}

static void FBShimmeringLayerAnimationApplyDragCoefficient(CAAnimation *animation)
{
  CGFloat k = FBShimmeringLayerDragCoefficient();
  
  if (k != 0 && k != 1) {
    animation.speed = 1 / k;
  }
}

// animations keys
static NSString *const kFBShimmerSlideAnimationKey = @"slide";
static NSString *const kFBFadeAnimationKey = @"fade";
static NSString *const kFBEndFadeAnimationKey = @"fade-end";

static CABasicAnimation *fade_animation(id delegate, CALayer *layer, CGFloat opacity, CFTimeInterval duration)
{
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
  animation.delegate = delegate;
  animation.fromValue = @([(layer.presentationLayer ?: layer) opacity]);
  animation.toValue = @(opacity);
  animation.fillMode = kCAFillModeBoth;
  animation.removedOnCompletion = NO;
  animation.duration = duration;
  FBShimmeringLayerAnimationApplyDragCoefficient(animation);
  return animation;
}

static CABasicAnimation *shimmer_begin_fade_animation(id delegate, CALayer *layer, CGFloat opacity, CGFloat duration)
{
  return fade_animation(delegate, layer, opacity, duration);
}

static CABasicAnimation *shimmer_end_fade_animation(id delegate, CALayer *layer, CGFloat opacity, CGFloat duration)
{
  CABasicAnimation *animation = fade_animation(delegate, layer, opacity, duration);
  [animation setValue:@YES forKey:kFBEndFadeAnimationKey];
  return animation;
}

static CABasicAnimation *shimmer_slide_animation(id delegate, CFTimeInterval duration, FBShimmerDirection direction)
{
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
  animation.delegate = delegate;
  animation.toValue = [NSValue valueWithCGPoint:CGPointZero];
  animation.duration = duration;
  animation.repeatCount = HUGE_VALF;
  FBShimmeringLayerAnimationApplyDragCoefficient(animation);
  if (direction == FBShimmerDirectionLeft ||
      direction == FBShimmerDirectionUp) {
    animation.speed = -fabsf(animation.speed);
  }
  return animation;
}

// take a shimmer slide animation and turns into repeating
static CAAnimation *shimmer_slide_repeat(CAAnimation *a, CFTimeInterval duration, FBShimmerDirection direction)
{
  CAAnimation *anim = [a copy];
  anim.repeatCount = HUGE_VALF;
  anim.duration = duration;
  anim.speed = (direction == FBShimmerDirectionRight || direction == FBShimmerDirectionDown) ? fabsf(anim.speed) : -fabsf(anim.speed);
  return anim;
}

// take a shimmer slide animation and turns into finish
static CAAnimation *shimmer_slide_finish(CAAnimation *a)
{
  CAAnimation *anim = [a copy];
  anim.repeatCount = 0;
  return anim;
}

@interface FBShimmeringMaskLayer : CAGradientLayer
@property (readonly, nonatomic) CALayer *fadeLayer;
@end

@implementation FBShimmeringMaskLayer

- (instancetype)init
{
  self = [super init];
  if (nil != self) {
    _fadeLayer = [[CALayer alloc] init];
    _fadeLayer.backgroundColor = [UIColor whiteColor].CGColor;
    [self addSublayer:_fadeLayer];
  }
  return self;
}

- (void)layoutSublayers
{
  [super layoutSublayers];
  CGRect r = self.bounds;
  _fadeLayer.bounds = r;
  _fadeLayer.position = CGPointMake(CGRectGetMidX(r), CGRectGetMidY(r));
}

@end

@interface FBShimmeringLayer ()
@property (strong, nonatomic) FBShimmeringMaskLayer *maskLayer;
@end

@implementation FBShimmeringLayer
{
  CALayer *_contentLayer;
  FBShimmeringMaskLayer *_maskLayer;
}

#pragma mark - Lifecycle

@synthesize shimmering = _shimmering;
@synthesize shimmeringPauseDuration = _shimmeringPauseDuration;
@synthesize shimmeringAnimationOpacity = _shimmeringAnimationOpacity;
@synthesize shimmeringOpacity = _shimmeringOpacity;
@synthesize shimmeringSpeed = _shimmeringSpeed;
@synthesize shimmeringHighlightLength = _shimmeringHighlightLength;
@synthesize shimmeringDirection = _shimmeringDirection;
@synthesize shimmeringFadeTime = _shimmeringFadeTime;
@synthesize shimmeringBeginFadeDuration = _shimmeringBeginFadeDuration;
@synthesize shimmeringEndFadeDuration = _shimmeringEndFadeDuration;
@dynamic shimmeringHighlightWidth;

- (instancetype)init
{
  self = [super init];
  if (nil != self) {
    // default configuration
    _shimmeringPauseDuration = 0.4;
    _shimmeringSpeed = 230.0;
    _shimmeringHighlightLength = 1.0;
    _shimmeringAnimationOpacity = 0.5;
    _shimmeringOpacity = 1.0;
    _shimmeringDirection = FBShimmerDirectionRight;
    _shimmeringBeginFadeDuration = 0.1;
    _shimmeringEndFadeDuration = 0.3;
  }
  return self;
}

#pragma mark - Properties

- (void)setContentLayer:(CALayer *)contentLayer
{
  // reset mask
  self.maskLayer = nil;

  // note content layer and add for display
  _contentLayer = contentLayer;
  self.sublayers = contentLayer ? @[contentLayer] : nil;

  // update shimmering animation
  [self _updateShimmering];
}

- (void)setShimmering:(BOOL)shimmering
{
  if (shimmering != _shimmering) {
    _shimmering = shimmering;
    [self _updateShimmering];
  }
}

- (void)setShimmeringSpeed:(CGFloat)speed
{
  if (speed != _shimmeringSpeed) {
    _shimmeringSpeed = speed;
    [self _updateShimmering];
  }
}

- (void)setShimmeringHighlightLength:(CGFloat)length
{
  if (length != _shimmeringHighlightLength) {
    _shimmeringHighlightLength = length;
    [self _updateShimmering];
  }
}

- (void)setShimmeringDirection:(FBShimmerDirection)direction
{
  if (direction != _shimmeringDirection) {
    _shimmeringDirection = direction;
    [self _updateShimmering];
  }
}

- (void)setShimmeringPauseDuration:(CFTimeInterval)duration
{
  if (duration != _shimmeringPauseDuration) {
    _shimmeringPauseDuration = duration;
    [self _updateShimmering];
  }
}

- (void)setShimmeringAnimationOpacity:(CGFloat)shimmeringAnimationOpacity
{
    if (shimmeringAnimationOpacity != _shimmeringAnimationOpacity) {
        _shimmeringAnimationOpacity = shimmeringAnimationOpacity;
        [self _updateMaskColors];
    }
}

- (void)setShimmeringOpacity:(CGFloat)shimmeringOpacity
{
  if (shimmeringOpacity != _shimmeringOpacity) {
    _shimmeringOpacity = shimmeringOpacity;
    [self _updateMaskColors];
  }
}

- (void)layoutSublayers
{
  CGRect r = self.bounds;
  _contentLayer.anchorPoint = CGPointMake(0.5, 0.5);
  _contentLayer.bounds = r;
  _contentLayer.position = CGPointMake(CGRectGetMidX(r), CGRectGetMidY(r));
  
  if (nil != _maskLayer) {
    [self _updateMaskLayout];
  }
}

- (void)setBounds:(CGRect)bounds
{
  if (!CGRectEqualToRect(self.bounds, bounds)) {
    [super setBounds:bounds];

    [self _updateShimmering];
  }
}

#pragma mark - Internal

- (void)_clearMask
{
  if (nil == _maskLayer) {
    return;
  }

  BOOL disableActions = [CATransaction disableActions];
  [CATransaction setDisableActions:YES];

  self.maskLayer = nil;
  _contentLayer.mask = nil;
  
  [CATransaction setDisableActions:disableActions];
}

- (void)_createMaskIfNeeded
{
  if (_shimmering && !_maskLayer) {
    _maskLayer = [FBShimmeringMaskLayer layer];
    _maskLayer.delegate = self;
    _contentLayer.mask = _maskLayer;
    [self _updateMaskColors];
    [self _updateMaskLayout];
  }
}

- (void)_updateMaskColors
{
  if (nil == _maskLayer) {
    return;
  }

  // We create a gradient to be used as a mask.
  // In a mask, the colors do not matter, it's the alpha that decides the degree of masking.
  UIColor *maskedColor = [UIColor colorWithWhite:1.0 alpha:_shimmeringOpacity];
  UIColor *unmaskedColor = [UIColor colorWithWhite:1.0 alpha:_shimmeringAnimationOpacity];

  // Create a gradient from masked to unmasked to masked.
  _maskLayer.colors = @[(__bridge id)maskedColor.CGColor, (__bridge id)unmaskedColor.CGColor, (__bridge id)maskedColor.CGColor];
}

- (void)_updateMaskLayout
{
  // Everything outside the mask layer is hidden, so we need to create a mask long enough for the shimmered layer to be always covered by the mask.
  CGFloat length = 0.0f;
  if (_shimmeringDirection == FBShimmerDirectionDown ||
    _shimmeringDirection == FBShimmerDirectionUp) {
    length = CGRectGetHeight(_contentLayer.bounds);
  } else {
    length = CGRectGetWidth(_contentLayer.bounds);
  }
  if (0 == length) {
    return;
  }

  // extra distance for the gradient to travel during the pause.
  CGFloat extraDistance = length + _shimmeringSpeed * _shimmeringPauseDuration;

  // compute how far the shimmering goes
  CGFloat fullShimmerLength = length * 3.0f + extraDistance;
  CGFloat travelDistance = length * 2.0f + extraDistance;
  
  // position the gradient for the desired width
  CGFloat highlightOutsideLength = (1.0 - _shimmeringHighlightLength) / 2.0;
  _maskLayer.locations = @[@(highlightOutsideLength),
                           @(0.5),
                           @(1.0 - highlightOutsideLength)];

  CGFloat startPoint = (length + extraDistance) / fullShimmerLength;
  CGFloat endPoint = travelDistance / fullShimmerLength;
  
  // position for the start of the animation
  _maskLayer.anchorPoint = CGPointZero;
  if (_shimmeringDirection == FBShimmerDirectionDown ||
      _shimmeringDirection == FBShimmerDirectionUp) {
    _maskLayer.startPoint = CGPointMake(0.0, startPoint);
    _maskLayer.endPoint = CGPointMake(0.0, endPoint);
    _maskLayer.position = CGPointMake(0.0, -travelDistance);
    _maskLayer.bounds = CGRectMake(0.0, 0.0, CGRectGetWidth(_contentLayer.bounds), fullShimmerLength);
  } else {
    _maskLayer.startPoint = CGPointMake(startPoint, 0.0);
    _maskLayer.endPoint = CGPointMake(endPoint, 0.0);
    _maskLayer.position = CGPointMake(-travelDistance, 0.0);
    _maskLayer.bounds = CGRectMake(0.0, 0.0, fullShimmerLength, CGRectGetHeight(_contentLayer.bounds));
  }
}

- (void)_updateShimmering
{
  // create mask if needed
  [self _createMaskIfNeeded];

  // if not shimmering and no mask, noop
  if (!_shimmering && !_maskLayer) {
    return;
  }

  // ensure layed out
  [self layoutIfNeeded];

  BOOL disableActions = [CATransaction disableActions];
  if (!_shimmering) {
    if (disableActions) {
      // simply remove mask
      [self _clearMask];
    } else {
      // end slide
      CFTimeInterval slideEndTime = 0;

      CAAnimation *slideAnimation = [_maskLayer animationForKey:kFBShimmerSlideAnimationKey];
      if (slideAnimation != nil) {
        // determing total time sliding
        CFTimeInterval now = CACurrentMediaTime();
        CFTimeInterval slideTotalDuration = now - slideAnimation.beginTime;

        // determine time offset into current slide
        CFTimeInterval slideTimeOffset = fmod(slideTotalDuration, slideAnimation.duration);

        // transition to non-repeating slide
        CAAnimation *finishAnimation = shimmer_slide_finish(slideAnimation);

        // adjust begin time to now - offset
        finishAnimation.beginTime = now - slideTimeOffset;

        // note slide end time and begin
        slideEndTime = finishAnimation.beginTime + slideAnimation.duration;
        [_maskLayer addAnimation:finishAnimation forKey:kFBShimmerSlideAnimationKey];
      }

      // fade in text at slideEndTime
      CABasicAnimation *fadeInAnimation = shimmer_end_fade_animation(self, _maskLayer.fadeLayer, 1.0, _shimmeringEndFadeDuration);
      fadeInAnimation.beginTime = slideEndTime;
      [_maskLayer.fadeLayer addAnimation:fadeInAnimation forKey:kFBFadeAnimationKey];

      // expose end time for synchronization
      _shimmeringFadeTime = slideEndTime;
    }
  } else {
    // fade out text, optionally animated
    CABasicAnimation *fadeOutAnimation = nil;
    if (_shimmeringBeginFadeDuration > 0.0 && !disableActions) {
      fadeOutAnimation = shimmer_begin_fade_animation(self, _maskLayer.fadeLayer, 0.0, _shimmeringBeginFadeDuration);
      [_maskLayer.fadeLayer addAnimation:fadeOutAnimation forKey:kFBFadeAnimationKey];
    } else {
      BOOL innerDisableActions = [CATransaction disableActions];
      [CATransaction setDisableActions:YES];

      _maskLayer.fadeLayer.opacity = 0.0;
      [_maskLayer.fadeLayer removeAllAnimations];
      
      [CATransaction setDisableActions:innerDisableActions];
    }

    // begin slide animation
    CAAnimation *slideAnimation = [_maskLayer animationForKey:kFBShimmerSlideAnimationKey];
    
    // compute shimmer duration
    CFTimeInterval animationDuration = (CGRectGetWidth(_contentLayer.bounds) / _shimmeringSpeed) + _shimmeringPauseDuration;
    
    if (slideAnimation != nil) {
      // ensure existing slide animation repeats
      [_maskLayer addAnimation:shimmer_slide_repeat(slideAnimation, animationDuration, _shimmeringDirection) forKey:kFBShimmerSlideAnimationKey];
    } else {
      // add slide animation
      slideAnimation = shimmer_slide_animation(self, animationDuration, _shimmeringDirection);
      slideAnimation.fillMode = kCAFillModeForwards;
      slideAnimation.removedOnCompletion = NO;
      slideAnimation.beginTime = CACurrentMediaTime() + fadeOutAnimation.duration;
      [_maskLayer addAnimation:slideAnimation forKey:kFBShimmerSlideAnimationKey];
    }
  }
}

#pragma mark - CALayerDelegate

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
  // no associated actions
  return (id)kCFNull;
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
  if (flag && [[anim valueForKey:kFBEndFadeAnimationKey] boolValue]) {
    [self _clearMask];
  }
}

@end
