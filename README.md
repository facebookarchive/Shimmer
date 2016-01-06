Note : This repository it's a simple fork of [Facebook/Shimmer](https://github.com/facebook/Shimmer) with carthage support

# Shimmer

Shimmer is an easy way to add a shimmering effect to any view in your app. It's useful as an unobtrusive loading indicator.

Shimmer was originally developed to show loading status in [Paper](http://facebook.com/paper).

![Shimmer](https://github.com/facebook/Shimmer/blob/master/shimmer.gif?raw=true)

## Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Alamofire into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "PoissonBallon/Shimmer"
```

Run `carthage update --platform ios` to build the framework and drag the built `Alamofire.framework` into your Xcode project.

Note : Other platform possibly work but not tested  


## Usage

```swift
import Shimmer

let lShimer = FBShimmeringView(frame: CGRectMake(0, 0, 200, 200))
self.contentView.addSubview(lShimer)
let lLabel = UILabel(frame: lShimer.bounds)
lLabel.text = "I am the doctor"
lShimer.contentView = lLabel
lShimer.shimmering = true

```

## Licence and Contributing

See the CONTRIBUTING file for how to help out.

Shimmer is BSD-licensed. We also provide an additional patent grant.
