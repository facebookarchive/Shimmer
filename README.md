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

### [Cocoapods](http://cocoapods.org)
Shimmer is available on CocoaPods. Add the following to your Podfile:

``` 
target 'MyApp' do
	pod "Shimmer"
end 
```

Quit Xcode completely before running
> `pod install`
in the project directory in Terminal.

To update your version of Shimmer, run
> `pod update Shimmer `

in the project directory in Terminal.

Don’t forget to use the workspace .xcworkspace file, not the project .xcodeproj file.

### [Carthage](https://github.com/Carthage/Carthage)
The standard way to use Carthage is to have a Cartfile list the dependencies, and then run carthage update to download the dependenices into the Cathage/Checkouts folder and build each of those into frameworks located in the Carthage/Build folder, and finally the developer has to manually integrate in the project.

Shimmer is also available through Carthage.

Add the following to your Cartfile to get the latest release branch:
`github "facebook/Shimmer"`

Run
> `carthage update`
 
Or you can update Only Shimmer 
> `carthage update Shimmer --platform iOS --no-use-binaries`

in Terminal. This will fetch dependencies into a Carthage/Checkouts folder, then build each one.

### Manually 
Add the files into your Xcode project. Slightly simpler, but updates are also manual.

Shimmer requires iOS 6 or later.

## How it works
Shimmer uses the `-[CALayer mask]` property to enable shimmering, similar to what's described in John Harper's 2009 WWDC talk (unfortunately no longer online). Shimmer uses CoreAnimation's timing features to smoothly transition "on-beat" when starting and stopping the shimmer.

## Other Platforms

We have a version of Shimmer for Android, too! It's [also available on GitHub](https://github.com/facebook/shimmer-android).

## Contributing
See the CONTRIBUTING file for how to help out.

## License
Shimmer is BSD-licensed. 

