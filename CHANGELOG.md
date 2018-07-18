## [0.0.13] - 7-18-2018

* Added polyline support. Major thanks to @LJaraCastillo
* Dart2 updates

## [0.0.12] - 4-17-2018

* Update gradle dependencies

## [0.0.11] - 04-15-2018
* Fixed iOS getting current location. Thanks to @nunorpg
* Added MIT License
* Added satellite support for static maps thanks to @grepLines 

## [0.0.10] - 12-30-2017
* Fixed bug where adding annotations would fail after displaying map a second time.

## [0.0.8] - 12-29-2017
* Another attempt at fixing dependency problems

## [0.0.7] - 12-29-2017
* Fixed dependency problem with uri package.

## [0.0.9] - 12-30-2017

* Added isEqual check for Marker
* Add removeMarker

## [0.0.6] - 12-27-2017

* Improved README for easier project integration
* Added StaticMapProvider for generating static map images for inline display
    * Supports generating an image for center and zoom level
    * Supports generating an image given a list of markers
    * Supports generating an image given a current active MapView ( will copy visible annotations, center and zoom to generate static image)
* MapView now exports all public classes so you only have to import `package:map_view/map_view.dart`
* Added support for info window tap events thanks to [HelenGuov](https://github.com/HelenGuov)
* Added support for changing map type (normal, satellite, terrain) thanks to [HelenGuov](https://github.com/HelenGuov)

## [0.0.5] - 11-14-2017

* Improved setup documentation

## [0.0.4] - 11-08-2017

* Updated Authors for pub.dartlang.com

## [0.0.3] - 11-08-2017

* Fixed Google Play Services dependency - https://github.com/apptreesoftware/flutter_google_map_view/issues/1
* Added check for valid Google Play Services before displaying map. Will show dialog if out of date with option to update

## [0.0.2] - 11-07-2017

* Improved examples

## [0.0.1] - 11-07-2017

* Full Screen Map Support
* iOS Support
* Android Support
* Support for adding map pins
* Support for location change updates
* Support for camera position updates
* Support for marker touch callbacks
* Support for map tap callbacks
* Support for zooming to annotation(s)
* Support for setting camera position
* Support for querying current viewport information
* Support for getting current visible pins
* Support for toolbar items
