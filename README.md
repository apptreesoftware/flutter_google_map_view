# map_view

A flutter plugin for displaying google maps on iOS and Android

Please note: API changes are likely as we continue to develop this plugin.

## Getting Started

### Generate your API Key
 
1. Go to: https://console.developers.google.com/
2. Enable `Maps SDK for Android`
3. Enable `Maps SDK for iOS`
4. Under `Credentials`, choose `Create Credential`. 
   - Note: For development, you can create an unrestricted API key that can be used on both iOS & Android. 
   For production it is highly recommended that you restrict. 

- More detailed instructions for Android can be found here: https://developers.google.com/maps/documentation/android-sdk/signup
- More detailed instructions for iOS can be found here: https://developers.google.com/maps/documentation/ios-sdk/get-api-key
 
 The way you register your API key on iOS vs Android is different. Make sure to read the next sections carefully.
 
### iOS
#### The maps plugin will request your users location when needed. iOS requires that you explain this usage in the Info.plist file
 1.  Set the NSLocationWhenInUseUsageDescription in `ios/Runner/Info.plist`. Example:
```xml
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Using location to display on a map</string>
```
    
 2. Prior to using the Map plugin, you must call MapView.setApiKey(String apiKey). Example:
```dart
   import 'package:map_view/map_view.dart';
   
   void main() {
     MapView.setApiKey("<your_api_key>");
     runApp(new MyApp());
   }
``` 
 
 ***Note***: If your iOS and Android API key are different, be sure to use your iOS API key here.
 
 3. Add code to show the MapView.  
    ```dart
    //Create an instance variable for the mapView
    var _mapView = new MapView();
    
    
    //Add a method to call to show the map.
    void showMap() {
        _mapView.show(new MapOptions(showUserLocation: true));
    }
      
    
    ```  
    
  4. Run your application on an iOS device or simulator. 
  Confirm that when you display the map you see map detail. 
  If you only see a beige screen it's possible that your API key is incorrect. When your API 
  key is incorrect you'll see messages like this in the console:
  
  ```text
  ClientParametersRequest failed, 7 attempts remaining (0 vs 12). Error Domain=com.google.HTTPStatus Code=400 "(null)" UserInfo={data=<>}
  ```
  
  #### Common API Key problems for iOS
  1. Your Bundle ID does not match what is registered in the Google API Console.
 When you create an restricted API key in the Google API console it asks you to specify your iOS bundle ID.
 Make sure that your iOS Bundle Identifier matches the one you registered in the console.
 
 2. Using the wrong key. If you made a separate key for iOS and Android, 
 make sure you are using the iOS key in the MapView.setApiKey() call.
 
### Android

You will be making multiple edits to your `AndroidManifest.xml` file. In your Flutter project, you can
find this file location under `android/app/src/main`

1. In your `AndroidManifest.xml`, add the following uses-permission above the <application> tag.
    ```xml
        <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
        <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    ```
2. In your AndroidManifest.xml, add the following lines inside of the `application` tag. Be sure to replace `your_api_key` with the one you generated.
    ```xml
        <meta-data android:name="com.google.android.maps.v2.API_KEY" android:value="your_api_key"/>
        <meta-data android:name="com.google.android.gms.version" android:value="@integer/google_play_services_version"/>
    ```
3. Add the MapActivity to your AndroidManifest.xml
    ```xml
        <activity android:name="com.apptreesoftware.mapview.MapActivity" android:theme="@style/Theme.AppCompat.Light.DarkActionBar"/>
    ```
4. In your `android/build.gradle` file. Under `buildScript` `dependencies` add:
    ```groovy
        classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:1.1.2-4'
    ```
   
5. Run your application on an Android device or simulator. 
     Confirm that when you display the map you see map detail. 
     If you only see a beige screen it's possible that your API key is incorrect.


### Static Maps for Inline display

This plugin does not currently support displaying a Google Map within the
Flutter widget hierarchy. A common workaround for this is to show a static image using the
 [Google Static Maps API](https://developers.google.com/maps/documentation/maps-static/intro).
Included in this Plugin is the StaticMapProvider class which will allow you to easily generate
a static map. The Static Maps API also requires an API Key and you must enable the API within the Google API Console.

1. Go to: https://console.developers.google.com/
2. Enable `Maps Static API`
3. Once enabled, you can use the same API key you generated for iOS/Android.
4. Initialize the StaticMapProvider
    ```dart
    var provider = new StaticMapProvider('your_api_key');
    ``` 
5. The StaticMapProvider offers a few different APIs for generating static maps. If you 
want to generate an image for the current viewport of your full screen interactive map
you can use:
```dart
var uri = staticMapProvider.getImageUriFromMap(mapView,
                  width: 900, height: 400);
```
  
 
You can refer to the [example](https://github.com/apptreesoftware/flutter_google_map_view/raw/master/example) project if you run into any issues with these steps.


<table>
<tr><td>
<img src='https://github.com/apptreesoftware/flutter_google_map_view/raw/master/example/Android_screen.png' width=320/>
</td>
<td>
<img src='https://github.com/apptreesoftware/flutter_google_map_view/raw/master/example/iOS_Screen.png' width=320/>
</td>
</tr>
</table>

 
## Features

- [X] iOS Support
- [X] Android Support
- [X] Toolbar support
- [X] Update Camera position
- [X] Add Map pins
- [X] Receive map pin touch callbacks
- [X] Receive map touch callbacks
- [X] Receive location change callbacks
- [X] Receive camera change callbacks
- [X] Zoom to a set of annotations
- [X] Customize Pin color
- [X] Polyline support
- [X] Polygon support
- [X] Customize pin image
- [X] Remove markers, polylines & polygons.

### Upcoming

- [ ] Bounds geometry functions

## Usage examples

#### Show a map ( with a toolbar )
```dart
mapView.show(
        new MapOptions(
            mapViewType: MapViewType.normal,
            showUserLocation: true,
            initialCameraPosition: new CameraPosition(
                new Location(45.5235258, -122.6732493), 14.0),
            title: "Recently Visited"),
        toolbarActions: [new ToolbarAction("Close", 1)]);
```

#### Get notified when the map is ready
```dart
mapView.onMapReady.listen((_) {
  print("Map ready");
});
```
#### Add multiple pins to the map
```dart
mapView.setMarkers(<Marker>[
    new Marker("1", "Work", 45.523970, -122.663081, color: Colors.blue),
    new Marker("2", "Nossa Familia Coffee", 45.528788, -122.684633),
]);
```

#### Add a single pin to the map
```dart
mapView.addMarker(new Marker("3", "10 Barrel", 45.5259467, -122.687747,
        color: Colors.purple));
```

#### Edit custom Marker image
First add your assets to a folder in your project directory. The name of the folder could be any but "images" or "assets" are the more common.
It should look like this.

```dart
- project_name
    |-android
    |-images
        |-flower_vase.png
    |-ios
    |-lib
    # Rest of project folders and files
```

Then add asset to the pubspec.yaml under flutter tag.
```dart
flutter:
    # Code already existent

    # Added asset.
    assets:
        - images/flower_vase.png
```

Finally use the asset name as icon for your marker. If the width or height is not set or is equals to 0, the image original value of said attribute will be used.

```dart
new Marker(
      "1",
      "Something fragile!",
      45.52480841512737,
      -122.66201455146073,
      color: Colors.blue,
      draggable: true, //Allows the user to move the marker.
      markerIcon: new MarkerIcon(
        "images/flower_vase.png", //Asset to be used as icon
        width: 112.0, //New width for the asset
        height: 75.0, // New height for the asset
      ),
    );
```
#### Set a Marker draggable and listening to position changes
First set the draggable attribute of a marker to true.
```dart
Marker marker=new Marker(
      "1",
      "Something fragile!",
      45.52480841512737,
      -122.66201455146073,
      draggable: true, //Allows the user to move the marker.
    );
```
Now add listeners for the events.
```dart
// This listener fires when the marker is long pressed and could be moved.
mapView.onAnnotationDragStart.listen((markerMap) {
      var marker = markerMap.keys.first;
      var location = markerMap[marker]; // The original location of the marker before moving it. Use it if needed.
      print("Annotation ${marker.id} dragging started");
    });
// This listener fires when the user releases the marker.
mapView.onAnnotationDragEnd.listen((markerMap) {
      var marker = markerMap.keys.first;
      var location = markerMap[marker]; // The actual position of the marker after finishing the dragging.
      print("Annotation ${marker.id} dragging ended");
    });
// This listener fires every time the marker changes position.
mapView.onAnnotationDrag.listen((markerMap) {
      var marker = markerMap.keys.first;
      var location = markerMap[marker]; // The updated position of the marker.
      print("Annotation ${marker.id} moved to ${location.latitude} , ${location
          .longitude}");
    });
```

#### Add a single polyline to the map
```dart
mapView.addPolyline(new Polyline(
          "12",
          <Location>[
            new Location(45.519698, -122.674932),
            new Location(45.516687, -122.667014),
          ],
          width: 15.0));
```

#### Add multiple polylines to the map
```dart
mapView.setPolylines(<Polyline>[
        new Polyline(
          "11",
          <Location>[
            new Location(45.523970, -122.663081),
            new Location(45.528788, -122.684633),
            new Location(45.528864, -122.667195),
          ],
          jointType: FigureJointType.round,
          width: 15.0,
          color: Colors.orangeAccent,
        ),
        new Polyline(
          "12",
          <Location>[
            new Location(45.519698, -122.674932),
            new Location(45.516687, -122.667014),
          ],
          width: 15.0,
        ),
      ]);
```

#### Add a single polygon to the map
```dart
mapView.addPolygon(new Polygon(
                                 "111",
                                 <Location>[
                                   new Location(45.5231233, -122.6733130),
                                   new Location(45.5233225, -122.6732969),
                                   new Location(45.5232398, -122.6733506),
                                   new Location(45.5231233, -122.6733130),
                                 ],
                                 jointType: FigureJointType.round,
                                 strokeWidth: 5.0,
                                 strokeColor: Colors.red,
                                 fillColor: Color.fromARGB(75, 255, 0, 0),
                                 ));
```

#### Add multiple polygons to the map
```dart
 mapView.setPolygons(<Polygon>[
        new Polygon(
            "111",
            <Location>[
              new Location(42.9274334, -72.2811234),
              new Location(42.9258230, -72.2808444),
              new Location(42.9261294, -72.2779906),
              new Location(42.9275120, -72.2779155),
            ],
            //you can add a hole inside the polygon
            holes: <Hole>[
              new Hole(
                <Location>[
                  new Location(42.9270721, -72.2797287),
                  new Location(42.9266400, -72.2796750),
                  new Location(42.9267186, -72.2790956),
                  new Location(42.9270014, -72.2790956),
                ],
              ),
            ],
            jointType: FigureJointType.round,
            strokeWidth: 5.0,
            strokeColor: Colors.red,
            fillColor: Color.fromARGB(75, 255, 0, 0)),
        new Polygon(
            "111",
            <Location>[
              new Location(45.5231233, -122.6733130),
              new Location(45.5233225, -122.6732969),
              new Location(45.5232398, -122.6733506),
              new Location(45.5231233, -122.6733130),
            ],
            jointType: FigureJointType.round,
            strokeWidth: 5.0,
            strokeColor: Colors.red,
            fillColor: Color.fromARGB(75, 255, 0, 0)),
      ]);
```

#### Remove elements from the map
```dart
//Remove all markers
mapView.clearA
```

#### Zoom to fit all the pins on the map
```dart
mapView.zoomToFit(padding: 100);
```

#### Receive location updates of the users current location
```dart
mapView.onLocationUpdated
     .listen((location) => print("Location updated $location"));
```

#### Receive marker, polyline & polygon touches
```dart
//Marker
mapView.onTouchAnnotation.listen((annotation) => print("annotation ${annotation.id} tapped"));
//Polyline
mapView.onTouchPolyline.listen((polyline) => print("polyline ${polyline.id} tapped"));
//Polygon
mapView.onTouchPolygon.listen((polygon) => print("polygon ${polygon.id} tapped"));
```

#### Receive map touches
```dart
mapView.onMapTapped
     .listen((location) => print("Touched location $location"));
```

#### Receive camera change updates
```dart
mapView.onCameraChanged.listen((cameraPosition) =>
     this.setState(() => this.cameraPosition = cameraPosition));
```

#### Receive toolbar actions
```dart
mapView.onToolbarAction.listen((id) {
  if (id == 1) {
    _handleDismiss();
    }
});
```
#### Get the current zoom level
```dart
double zoomLevel = await mapView.zoomLevel;
```
#### Get the maps center location
```dart
Location centerLocation = await mapView.centerLocation;
```
#### Get the visible markers on screen
```dart
List<Marker> visibleAnnotations = await mapView.visibleAnnotations;
```
