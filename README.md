# FluxxKit

[![CI Status](http://img.shields.io/travis/keitaoouchi/FluxxKit.svg?style=flat)](https://travis-ci.org/keitaoouchi/FluxxKit)
[![Swift 3.0](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://swift.org/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/FluxxKit.svg?style=flat)](http://cocoapods.org/pods/FluxxKit)
[![License](https://img.shields.io/cocoapods/l/FluxxKit.svg?style=flat)](http://cocoapods.org/pods/FluxxKit)
[![Platform](https://img.shields.io/cocoapods/p/FluxxKit.svg?style=flat)](http://cocoapods.org/pods/FluxxKit)

## Overview

Unidirectional data flow for reactive programming in iOS.

Porting [facebook's flux implementation](https://github.com/facebook/flux) in Swift, except callback called when store changes.

##### Why no callback?

We have RxSwift, ReactiveSwift, ReactiveKit or something else. All the stateful things could be implemented as Observable or Stream, and ViewController could bind and react to them.

### Scenario

(nice diagram here :ghost:)

#### Flux

- When a user interacts with a View(Controller), it propagates an `Action`
- through a central `Dispatcher`,
- to the various `Store`s that hold the application's data,
- `state transition` occurs in some `Store` that could responds to dispatched `Action`,
- which will emit new items to `Observable` property in these `Store`.

#### Reactive Programming

- ViewController subscribes Store's `Observable` properties,
- and react to it.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

More complicated real world example is [here](https://github.com/keitaoouchi/FluxxKitExample).

## Requirements

iOS 9 or later.
Swift3.0 or later.

## Installation

FluxxKit is available through [CocoaPods](http://cocoapods.org) or [Carthage](https://github.com/Carthage/Carthage).

### CocoaPods

```ruby
pod "FluxxKit"
```

### Carthage

```
github "keitaoouchi/FluxxKit"
```

for detail, please follow the [Carthage Instruction](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos)

## Author

keitaoouchi, keita.oouchi@gmail.com

## License

FluxxKit is available under the MIT license. See the LICENSE file for more info.
