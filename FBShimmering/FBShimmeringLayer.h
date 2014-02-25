/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <QuartzCore/CALayer.h>

#import "FBShimmering.h"

/**
  @abstract Lightweight, generic shimmering layer.
 */
@interface FBShimmeringLayer : CALayer <FBShimmering>

//! @abstract The content layer to be shimmered.
@property (strong, nonatomic) CALayer *contentLayer;

@end
