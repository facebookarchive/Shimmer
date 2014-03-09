# Shimmer
Shimmer is an easy way to add a shimmering effect to any view in your app. It's useful as an unobtrusive loading indicator.

Shimmer was originally developed to show loading status in [Paper](http://facebook.com/paper).

![Shimmer](https://github.com/facebook/Shimmer/blob/master/shimmer.gif?raw=true)

## Usage
To use Shimmer, create a `FBShimmeringView` or `FBShimmeringLayer` and add your content. To start shimmering, set the `shimmering` property to `YES`.

An example of making a label shimmer:

```objective-c
FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:self.view.bounds];
[self.view addSubview:shimmeringView];

UILabel *loadingLabel = [[UILabel alloc] initWithFrame:shimmeringView.bounds];
loadingLabel.textAlignment = NSTextAlignmentCenter;
loadingLabel.text = NSLocalizedString(@"Shimmer", nil);
shimmeringView.contentView = loadingLabel;

// Start shimmering.
shimmeringView.shimmering = YES;
```

There's also an example project. In the example, you can swipe horizontally and vertically to try various shimmering parameters, or tap to start or stop shimmering. (To build the example locally, you'll need to open `FBShimmering.xcworkpace` rather than the `.xcodeproj`.)

## Installation
There are two options:

 1. Shimmer is available as `Shimmer` in [Cocoapods](http://cocoapods.org).
 2. Manually add the files into your Xcode project. Slightly simpler, but updates are also manual.

Shimmer requires iOS 6 or later.

## How it works
Shimmer uses the `-[CALayer mask]` property to enable shimmering, similar to what's described in John Harper's 2009 WWDC talk (unfortunately no longer online). Shimmer uses CoreAnimation's timing features to smoothly transition "on-beat" when starting and stopping the shimmer.

## Contributing
See the CONTRIBUTING file for how to help out.

## License
Shimmer is BSD-licensed. We also provide an additional patent grant.

