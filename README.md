# map_view

A flutter plugin for displaying google maps on iOS and Android

Please note: API changes are likely as we continue to develop this plugin.

## Getting Started

### iOS
    1. Set the NSLocationWhenInUseUsageDescription in your Info.plist
    2. Your Google Map API key must be set using the MapView.setApiKey prior to displaying the MapView
### Android
    1. In your AndroidManifest.xml, add the following uses-permission
        <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
        <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    2. Also add your Google Maps API Key
        <meta-data android:name="com.google.android.maps.v2.API_KEY" android:value="your_api_key"/>
        <meta-data android:name="com.google.android.gms.version" android:value="@integer/google_play_services_version"/>

 
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

