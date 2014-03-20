/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FBShimmerDirection) {
    FBShimmerDirectionRight,    // Shimmer animation goes from left to right
    FBShimmerDirectionLeft      // Shimmer animation goes from right to left
};

@protocol FBShimmering <NSObject>

//! @abstract Set this to YES to start shimming and NO to stop. Defaults to NO.
@property (nonatomic, assign, readwrite, getter = isShimmering) BOOL shimmering;

//! @abstract The time interval between shimmerings in seconds. Defaults to 0.4.
@property (assign, nonatomic, readwrite) CFTimeInterval shimmeringPauseDuration;

//! @abstract The opacity of the content while it is shimmering. Defaults to 0.5.
@property (assign, nonatomic, readwrite) CGFloat shimmeringOpacity;

//! @abstract The speed of shimmering, in points per second. Defaults to 230.
@property (assign, nonatomic, readwrite) CGFloat shimmeringSpeed;

//! @abstract The highlight width of shimmering. Range of [0,1], defaults to 0.33.
@property (assign, nonatomic, readwrite) CGFloat shimmeringHighlightWidth;

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

@end

