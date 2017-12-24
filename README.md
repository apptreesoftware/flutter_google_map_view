# map_view

A flutter plugin for displaying google maps on iOS and Android

Please note: API changes are likely as we continue to develop this plugin.

## Getting Started

### Generate your API Key
 
1. Go to: https://console.developers.google.com/
2. Enable `Google Maps Android API`
3. Enable `Google Maps SDK for iOS`
4. Under `Credentials`, choose `Create Credential`. 
   - Note: For development, you can create an unrestricted API key that can be used on both iOS & Android. 
   For production it is highly recommended that you restrict. 

- More detailed instructions for Android can be found here: https://developers.google.com/maps/documentation/android-api/signup
- More detailed instructions for iOS can be found here: https://developers.google.com/maps/documentation/ios-sdk/get-api-key
 
 The way you register your API key on iOS vs Android is different. Make sure to read the next sections carefully.
 
### iOS
#### The maps plugin will request your users location when needed. iOS requires that you explain this usage in the Info.plist file
 1.  Set the NSLocationWhenInUseUsageDescription in ios/Info.plist. Example:
```
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Using location to display on a map</string>
```
    
 2. Prior to using the Map plugin, you must call MapView.setApiKey(String apiKey). Example:
```
   void main() {
     MapView.setApiKey("<your_api_key>");
     runApp(new MyApp());
   }
``` 
 
 ***Note***: If your iOS and Android API key are different, be sure to use your iOS API key here.
 
### Android

1. In your AndroidManifest.xml, add the following uses-permission
```
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>```
```
2. In your AndroidManifest.xml, add the Android Maps API Key you previously generated.
```
    <meta-data android:name="com.google.android.maps.v2.API_KEY" android:value="your_api_key"/>
    <meta-data android:name="com.google.android.gms.version" android:value="@integer/google_play_services_version"/>
```
3. Add the MapActivity to your AndroidManifest.xml
```
    <activity android:name="com.apptreesoftware.mapview.MapActivity" android:theme="@style/Theme.AppCompat.Light.DarkActionBar"/>
```
4. In your android/build.gradle file. Under buildScript dependencies add:
```
    classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:1.1.2-4'
```
   
You can refer to the example project if you run into any issues with these steps.


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

### Upcoming
- [ ] Customize pin image
- [ ] Remove markers
- [ ] Bounds geometry functions
- [ ] Polyline support

## Usage examples

#### Show a map ( with a toolbar )
    mapView.show(
        new MapOptions(
            showUserLocation: true,
            initialCameraPosition: new CameraPosition(
                new Location(45.5235258, -122.6732493), 14.0),
            title: "Recently Visited"),
        toolbarActions: [new ToolbarAction("Close", 1)]);
#### Get notified when the map is ready
    mapView.onMapReady.listen((_) {
      print("Map ready");
    });
#### Add multiple pins to the map 
    mapView.setMarkers(<Marker>[
      new Marker("1", "Work", 45.523970, -122.663081, color: Colors.blue),
      new Marker("2", "Nossa Familia Coffee", 45.528788, -122.684633),
    ]);

#### Add a single pin to the map
    mapView.addMarker(new Marker("3", "10 Barrel", 45.5259467, -122.687747,
        color: Colors.purple));
        
#### Zoom to fit all the pins on the map
    mapView.zoomToFit(padding: 100);

#### Receive location updates of the users current location
    mapView.onLocationUpdated
        .listen((location) => print("Location updated $location"));

#### Receive marker touches
    mapView.onTouchAnnotation.listen((marker) => print("marker tapped"));

#### Receive map touches
    mapView.onMapTapped
        .listen((location) => print("Touched location $location"));

#### Receive camera change updates
    mapView.onCameraChanged.listen((cameraPosition) =>
        this.setState(() => this.cameraPosition = cameraPosition));

#### Receive toolbar actions
    mapView.onToolbarAction.listen((id) {
      if (id == 1) {
        _handleDismiss();
      }
    });
    
#### Get the current zoom level
    double zoomLevel = await mapView.zoomLevel;
#### Get the maps center location
    Location centerLocation = await mapView.centerLocation;
#### Get the visible markers on screen
    List<Marker> visibleAnnotations = await mapView.visibleAnnotations;
