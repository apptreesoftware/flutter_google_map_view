# map_view

A flutter plugin for displaying google maps on iOS and Android

Please note: API changes are likely as we continue to develop this plugin.

<table>
<tr><td>
<img src='https://github.com/apptreesoftware/flutter_google_map_view/raw/master/example/Android_screen.png' width=320/>
</td>
<td>
<img src='https://github.com/apptreesoftware/flutter_google_map_view/raw/master/example/iOS_Screen.png' width=320/>
</td>
</tr>
</table>

## Getting Started

### iOS
    1. Set the NSLocationWhenInUseUsageDescription in your Info.plist
    2. Your Google Map API key must be set using the MapView.setApiKey prior to displaying the MapView
### Android
```
1. In your AndroidManifest.xml, add the following uses-permission
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
2. Also add your Google Maps API Key
    <meta-data android:name="com.google.android.maps.v2.API_KEY" android:value="your_api_key"/>
    <meta-data android:name="com.google.android.gms.version" android:value="@integer/google_play_services_version"/>
 ```

 
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
