/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FBShimmerDirection) {
    FBShimmerDirectionRight,    // Shimmer animation goes from left to right
    FBShimmerDirectionLeft,     // Shimmer animation goes from right to left
    FBShimmerDirectionUp,       // Shimmer animation goes from below to above
    FBShimmerDirectionDown,     // Shimmer animation goes from above to below
};

static const float FBShimmerDefaultBeginTime = CGFLOAT_MAX;

@protocol FBShimmering <NSObject>

//! @abstract Set this to YES to start shimming and NO to stop. Defaults to NO.
@property (assign, nonatomic, readwrite, getter = isShimmering) BOOL shimmering;

//! @abstract The time interval between shimmerings in seconds. Defaults to 0.4.
@property (assign, nonatomic, readwrite) CFTimeInterval shimmeringPauseDuration;

//! @abstract The opacity of the content while it is shimmering. Defaults to 0.5.
@property (assign, nonatomic, readwrite) CGFloat shimmeringAnimationOpacity;

//! @abstract The opacity of the content before it is shimmering. Defaults to 1.0.
@property (assign, nonatomic, readwrite) CGFloat shimmeringOpacity;

//! @abstract The speed of shimmering, in points per second. Defaults to 230.
@property (assign, nonatomic, readwrite) CGFloat shimmeringSpeed;

//! @abstract The highlight length of shimmering. Range of [0,1], defaults to 1.0.
@property (assign, nonatomic, readwrite) CGFloat shimmeringHighlightLength;

//! @abstract Same as "shimmeringHighlightLength", just for downward compatibility @deprecated
@property (assign, nonatomic, readwrite, getter = shimmeringHighlightLength, setter = setShimmeringHighlightLength:) CGFloat shimmeringHighlightWidth DEPRECATED_MSG_ATTRIBUTE("Use shimmeringHighlightLength");

//! @abstract The direction of shimmering animation. Defaults to FBShimmerDirectionRight.
@property (assign, nonatomic, readwrite) FBShimmerDirection shimmeringDirection;

//! @abstract The duration of the fade used when shimmer begins. Defaults to 0.1.
@property (assign, nonatomic, readwrite) CFTimeInterval shimmeringBeginFadeDuration;

//! @abstract The duration of the fade used when shimmer ends. Defaults to 0.3.
@property (assign, nonatomic, readwrite) CFTimeInterval shimmeringEndFadeDuration;

/**
 @abstract The absolute CoreAnimation media time when the shimmer will fade in.
 @discussion Only valid after setting {@ref shimmering} to NO.
 */
@property (assign, nonatomic, readonly) CFTimeInterval shimmeringFadeTime;

/**
 @abstract The absolute CoreAnimation media time when the shimmer will begin.
 @discussion Only valid after setting {@ref shimmering} to YES.
 */
@property (assign, nonatomic) CFTimeInterval shimmeringBeginTime;

@end

