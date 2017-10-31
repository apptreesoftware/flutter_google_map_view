import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  MapView mapView = new MapView();
  CameraPosition cameraPosition;

  @override
  initState() {
    super.initState();
    cameraPosition = new CameraPosition(new Location(0.0, 0.0), 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text('Plugin example app'),
          ),
          body: new Column(
            children: <Widget>[
              new MaterialButton(
                onPressed: showMap,
                child: new Text("Show Map"),
              ),
              new Text(
                  "Camera Position: ${cameraPosition.center.latitude}, ${cameraPosition.center.longitude}. Zoom: ${cameraPosition.zoom}"),
            ],
          )),
    );
  }

  showMap() {
    mapView.show(new MapOptions(showUserLocation: true, apiKey: "<your_key>"),
        toolbarActions: [new ToolbarAction("Close", 1)]);
    mapView.updateAnnotations(<MapAnnotation>[
      new MapAnnotation("1234", "Cupertino", 37.33527476, 122.408227),
    ]);
    mapView.zoomToFit();
    mapView.onLocationUpdated
        .listen((location) => print("Location updated $location"));
    mapView.onTouchAnnotation
        .listen((annotation) => print("Selected ${annotation.id}"));
    mapView.onMapTapped
        .listen((location) => print("Touched location $location"));
    mapView.onCameraChanged.listen((cameraPosition) =>
        this.setState(() => this.cameraPosition = cameraPosition));
    mapView.onToolbarAction.listen((id) {
      if (id == 1) {
        _handleDismiss();
      }
    });
  }

  _handleDismiss() async {
    double zoomLevel = await mapView.zoomLevel;
    Location centerLocation = await mapView.centerLocation;
    print("Zoom Level: $zoomLevel");
    print("Center: $centerLocation");
    mapView.dismiss();
  }
}
