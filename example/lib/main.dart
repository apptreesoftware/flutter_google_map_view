import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_view/figure_joint_type.dart';
import 'package:map_view/map_view.dart';
import 'package:map_view/polygon.dart';
import 'package:map_view/polyline.dart';

///This API Key will be used for both the interactive maps as well as the static maps.
///Make sure that you have enabled the following APIs in the Google API Console (https://console.developers.google.com/apis)
/// - Static Maps API
/// - Android Maps API
/// - iOS Maps API
const API_KEY = "<your-api-key>";

void main() {
  MapView.setApiKey(API_KEY);
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  MapView mapView = new MapView();
  CameraPosition cameraPosition;
  var compositeSubscription = new CompositeSubscription();
  var staticMapProvider = new StaticMapProvider(API_KEY);
  Uri staticMapUri;

  //Marker bubble
  List<Marker> _markers = <Marker>[
    new Marker(
      "1",
      "Something fragile!",
      45.52480841512737,
      -122.66201455146073,
      color: Colors.blue,
      draggable: true, //Allows the user to move the marker.
      markerIcon: new MarkerIcon(
        "images/flower_vase.png",
        width: 112.0,
        height: 75.0,
      ),
    ),
  ];

  //Line
  List<Polyline> _lines = <Polyline>[
    new Polyline(
        "11",
        <Location>[
          new Location(45.52309483308097, -122.67339684069155),
          new Location(45.52298442915803, -122.66339991241693),
        ],
        width: 15.0,
        color: Colors.blue),
  ];

  //Drawing
  List<Polygon> _polygons = <Polygon>[
    new Polygon(
        "111",
        <Location>[
          new Location(45.5231233, -122.6733130),
          new Location(45.5231195, -122.6706147),
          new Location(45.5231120, -122.6677823),
          new Location(45.5230894, -122.6670957),
          new Location(45.5230518, -122.6660979),
          new Location(45.5230518, -122.6655185),
          new Location(45.5232849, -122.6652074),
          new Location(45.5230443, -122.6649070),
          new Location(45.5230443, -122.6644135),
          new Location(45.5230518, -122.6639414),
          new Location(45.5231195, -122.6638663),
          new Location(45.5231947, -122.6638770),
          new Location(45.5233074, -122.6639950),
          new Location(45.5232698, -122.6643813),
          new Location(45.5235480, -122.6644349),
          new Location(45.5244349, -122.6645529),
          new Location(45.5245928, -122.6639628),
          new Location(45.5248108, -122.6632762),
          new Location(45.5249385, -122.6626861),
          new Location(45.5249310, -122.6622677),
          new Location(45.5250212, -122.6621926),
          new Location(45.5251490, -122.6621711),
          new Location(45.5251791, -122.6623106),
          new Location(45.5252242, -122.6625681),
          new Location(45.5251791, -122.6632118),
          new Location(45.5249010, -122.6640165),
          new Location(45.5247431, -122.6646388),
          new Location(45.5249611, -122.6646602),
          new Location(45.5253820, -122.6642525),
          new Location(45.5260811, -122.6642525),
          new Location(45.5260435, -122.6637161),
          new Location(45.5261713, -122.6635551),
          new Location(45.5263066, -122.6634800),
          new Location(45.5265471, -122.6635873),
          new Location(45.5269003, -122.6639628),
          new Location(45.5270356, -122.6642632),
          new Location(45.5271484, -122.6646602),
          new Location(45.5274866, -122.6649177),
          new Location(45.5271258, -122.6651645),
          new Location(45.5269605, -122.6653790),
          new Location(45.5267049, -122.6654434),
          new Location(45.5262990, -122.6657224),
          new Location(45.5261337, -122.6666021),
          new Location(45.5256677, -122.6678467),
          new Location(45.5245777, -122.6687801),
          new Location(45.5236908, -122.6690161),
          new Location(45.5233751, -122.6692307),
          new Location(45.5233826, -122.6714945),
          new Location(45.5233337, -122.6729804),
          new Location(45.5233225, -122.6732969),
          new Location(45.5232398, -122.6733506),
          new Location(45.5231233, -122.6733130),
        ],
        jointType: FigureJointType.bevel,
        strokeWidth: 5.0,
        strokeColor: Colors.red,
        fillColor: Color.fromARGB(75, 255, 0, 0)),
  ];

  @override
  initState() {
    super.initState();
    cameraPosition = new CameraPosition(Locations.portland, 2.0);
    staticMapUri = staticMapProvider.getStaticUri(Locations.portland, 12,
        width: 900, height: 400, mapType: StaticMapViewType.roadmap);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text('Map View Example'),
          ),
          body: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Container(
                height: 250.0,
                child: new Stack(
                  children: <Widget>[
                    new Center(
                        child: new Container(
                      child: new Text(
                        "You are supposed to see a map here.\n\nAPI Key is not valid.\n\n"
                            "To view maps in the example application set the "
                            "API_KEY variable in example/lib/main.dart. "
                            "\n\nIf you have set an API Key but you still see this text "
                            "make sure you have enabled all of the correct APIs "
                            "in the Google API Console. See README for more detail.",
                        textAlign: TextAlign.center,
                      ),
                      padding: const EdgeInsets.all(20.0),
                    )),
                    new InkWell(
                      child: new Center(
                        child: new Image.network(staticMapUri.toString()),
                      ),
                      onTap: showMap,
                    )
                  ],
                ),
              ),
              new Container(
                padding: new EdgeInsets.only(top: 10.0),
                child: new Text(
                  "Tap the map to interact",
                  style: new TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              new Container(
                padding: new EdgeInsets.only(top: 25.0),
                child:
                    new Text("Camera Position: \n\nLat: ${cameraPosition.center
                    .latitude}\n\nLng:${cameraPosition.center
                    .longitude}\n\nZoom: ${cameraPosition.zoom}"),
              ),
            ],
          )),
    );
  }

  showMap() {
    mapView.show(
        new MapOptions(
            mapViewType: MapViewType.normal,
            showUserLocation: true,
            showMyLocationButton: true,
            showCompassButton: true,
            initialCameraPosition: new CameraPosition(
                new Location(45.526607443935724, -122.66731660813093), 15.0),
            hideToolbar: false,
            title: "Recently Visited"),
        toolbarActions: [new ToolbarAction("Close", 1)]);
    StreamSubscription sub = mapView.onMapReady.listen((_) {
      mapView.setMarkers(_markers);
      mapView.setPolylines(_lines);
      mapView.setPolygons(_polygons);
    });
    compositeSubscription.add(sub);
    sub = mapView.onLocationUpdated.listen((location) {
      print("Location updated $location");
    });
    compositeSubscription.add(sub);
    sub = mapView.onTouchAnnotation
        .listen((annotation) => print("annotation ${annotation.id} tapped"));
    compositeSubscription.add(sub);
    sub = mapView.onTouchPolyline
        .listen((polyline) => print("polyline ${polyline.id} tapped"));
    compositeSubscription.add(sub);
    sub = mapView.onTouchPolygon
        .listen((polygon) => print("polygon ${polygon.id} tapped"));
    compositeSubscription.add(sub);
    sub = mapView.onMapTapped
        .listen((location) => print("Touched location $location"));
    compositeSubscription.add(sub);
    sub = mapView.onMapLongTapped
        .listen((location) => print("Long tapped location $location"));
    compositeSubscription.add(sub);
    sub = mapView.onCameraChanged.listen((cameraPosition) =>
        this.setState(() => this.cameraPosition = cameraPosition));
    compositeSubscription.add(sub);
    sub = mapView.onAnnotationDragStart.listen((markerMap) {
      var marker = markerMap.keys.first;
      print("Annotation ${marker.id} dragging started");
    });
    sub = mapView.onAnnotationDragEnd.listen((markerMap) {
      var marker = markerMap.keys.first;
      print("Annotation ${marker.id} dragging ended");
    });
    sub = mapView.onAnnotationDrag.listen((markerMap) {
      var marker = markerMap.keys.first;
      var location = markerMap[marker];
      print("Annotation ${marker.id} moved to ${location.latitude} , ${location
          .longitude}");
    });
    compositeSubscription.add(sub);
    sub = mapView.onToolbarAction.listen((id) {
      print("Toolbar button id = $id");
      if (id == 1) {
        _handleDismiss();
      }
    });
    compositeSubscription.add(sub);
    sub = mapView.onInfoWindowTapped.listen((marker) {
      print("Info Window Tapped for ${marker.title}");
    });
    compositeSubscription.add(sub);
    sub = mapView.onIndoorBuildingActivated.listen(
        (indoorBuilding) => print("Activated indoor building $indoorBuilding"));
    compositeSubscription.add(sub);
    sub = mapView.onIndoorLevelActivated.listen(
        (indoorLevel) => print("Activated indoor level $indoorLevel"));
    compositeSubscription.add(sub);
  }

  _handleDismiss() async {
    double zoomLevel = await mapView.zoomLevel;
    Location centerLocation = await mapView.centerLocation;
    List<Marker> visibleAnnotations = await mapView.visibleAnnotations;
    List<Polyline> visibleLines = await mapView.visiblePolyLines;
    List<Polygon> visiblePolygons = await mapView.visiblePolygons;
    print("Zoom Level: $zoomLevel");
    print("Center: $centerLocation");
    print("Visible Annotation Count: ${visibleAnnotations.length}");
    print("Visible Polylines Count: ${visibleLines.length}");
    print("Visible Polygons Count: ${visiblePolygons.length}");
    var uri = await staticMapProvider.getImageUriFromMap(mapView,
        width: 900, height: 400);
    setState(() => staticMapUri = uri);
    mapView.dismiss();
    compositeSubscription.cancel();
  }
}

class CompositeSubscription {
  Set<StreamSubscription> _subscriptions = new Set();

  void cancel() {
    for (var n in this._subscriptions) {
      n.cancel();
    }
    this._subscriptions = new Set();
  }

  void add(StreamSubscription subscription) {
    this._subscriptions.add(subscription);
  }

  void addAll(Iterable<StreamSubscription> subs) {
    _subscriptions.addAll(subs);
  }

  bool remove(StreamSubscription subscription) {
    return this._subscriptions.remove(subscription);
  }

  bool contains(StreamSubscription subscription) {
    return this._subscriptions.contains(subscription);
  }

  List<StreamSubscription> toList() {
    return this._subscriptions.toList();
  }
}
