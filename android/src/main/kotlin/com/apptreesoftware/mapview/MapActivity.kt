package com.apptreesoftware.mapview

import android.Manifest
import android.annotation.SuppressLint
import android.content.pm.PackageManager
import android.content.res.AssetFileDescriptor
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Bundle
import android.support.v4.app.ActivityCompat
import android.support.v4.content.ContextCompat
import android.support.v7.app.AppCompatActivity
import android.view.Menu
import android.view.MenuItem
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.SupportMapFragment
import com.google.android.gms.maps.model.*

class MapActivity : AppCompatActivity(),

    OnMapReadyCallback {
  var googleMap : GoogleMap? = null
  var markerIdLookup = HashMap<String, Marker>()
  val PermissionRequest = 1

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(R.layout.map_fragment)
    title = MapViewPlugin.mapTitle
    val mapFragment = supportFragmentManager.findFragmentById(
        R.id.map) as SupportMapFragment
    mapFragment.getMapAsync(this)
    MapViewPlugin.mapActivity = this
  }

  @SuppressLint("MissingPermission")
  override fun onMapReady(map: GoogleMap) {
    googleMap = map

    map.setMapType(MapViewPlugin.mapViewType)

    if (MapViewPlugin.showUserLocation) {
      if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
          != PackageManager.PERMISSION_GRANTED) {
        val array = arrayOf(Manifest.permission.ACCESS_FINE_LOCATION,
                            Manifest.permission.ACCESS_COARSE_LOCATION)
        ActivityCompat.requestPermissions(this, array, PermissionRequest)
      } else {
        map.isMyLocationEnabled = true
        map.uiSettings.isMyLocationButtonEnabled = MapViewPlugin.showUserLocation
        map.uiSettings.isIndoorLevelPickerEnabled = true
      }
    }

    map.setOnMapClickListener { latLng ->
        MapViewPlugin.mapTapped(latLng)
    }
    map.setOnMarkerClickListener { marker ->
      MapViewPlugin.annotationTapped(marker.tag as String)
      false
    }
    map.setOnCameraMoveListener {
      val pos = map.cameraPosition
      MapViewPlugin.cameraPositionChanged(pos)
    }
    map.setOnMyLocationChangeListener {
      val loc = map.myLocation ?: return@setOnMyLocationChangeListener
      MapViewPlugin.locationDidUpdate(loc)
    }
    map.setOnInfoWindowClickListener{ marker ->
        MapViewPlugin.infoWindowTapped(marker.tag as String)
    }
    map.moveCamera(CameraUpdateFactory.newCameraPosition(
        MapViewPlugin.initialCameraPosition))
      MapViewPlugin.onMapReady()
  }

  override fun onBackPressed(){
    MapViewPlugin.onBackButtonTapped()
    super.onBackPressed()
  }

  override fun onCreateOptionsMenu(menu: Menu): Boolean {
    MapViewPlugin.toolbarActions.forEach {
      val item = menu.add(0, it.identifier, 0, it.title)
      item.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM)
    }
    return super.onCreateOptionsMenu(menu)
  }


  override fun onOptionsItemSelected(item: MenuItem): Boolean {
      MapViewPlugin.handleToolbarAction(item.itemId)
    return true
  }

  override fun onDestroy() {
    super.onDestroy()
    MapViewPlugin.mapActivity = null
  }

  val zoomLevel : Float get() {
    return googleMap?.cameraPosition?.zoom ?: 0.0.toFloat()
  }

  val target : LatLng
      get() = googleMap?.cameraPosition?.target ?: LatLng(0.0,
                                                                                            0.0)

  fun setCamera(target : LatLng, zoom : Float){
    googleMap?.animateCamera(
        CameraUpdateFactory.newLatLngZoom(target, zoom))
  }

  fun setAnnotations(annotations : List<MapAnnotation>) {
    val map = this.googleMap ?: return
    map.clear()
    markerIdLookup.clear()
    for (annotation in annotations) {
      val marker = createMarkerForAnnotation(annotation, map)
      markerIdLookup[annotation.identifier] = marker
    }
  }

  fun addMarker(annotation : MapAnnotation) {
    val map = this.googleMap ?: return
    val existingMarker = markerIdLookup[annotation.identifier]
    if (existingMarker != null) return
    val marker = createMarkerForAnnotation(annotation, map)
    markerIdLookup.put(annotation.identifier, marker)
  }

  fun removeMarker(annotation : MapAnnotation) {
    this.googleMap ?: return
    val existingMarker = markerIdLookup[annotation.identifier] ?: return
    markerIdLookup.remove(annotation.identifier)
    existingMarker.remove()
  }

  val visibleMarkers : List<String> get() {
    val map = this.googleMap ?: return  emptyList()
    val region = map.projection.visibleRegion
    val visibleIds = ArrayList<String>()
    for (marker in markerIdLookup.values) {
      if (region.latLngBounds.contains(marker.position)) {
        visibleIds.add(marker.tag as String)
      }
    }
    return visibleIds
  }

  fun zoomToAnnotations(padding : Int) {
    val map = this.googleMap ?: return
    val bounds = LatLngBounds.Builder()
    var count = 0
    for (marker in markerIdLookup.values) {
      bounds.include(marker.position)
      count++
    }

    if(map.isMyLocationEnabled && map.myLocation != null) {
      if (count == 0) {
        map.animateCamera(CameraUpdateFactory.newLatLngZoom(
            LatLng(map.myLocation.latitude,
                                                     map.myLocation.longitude), 12.toFloat()))
        return
      }
      bounds.include(LatLng(map.myLocation.latitude,
                            map.myLocation.longitude))
    }
    try {
      map.animateCamera(
          CameraUpdateFactory.newLatLngBounds(bounds.build(), padding))
    } catch (e : Exception) {}
  }

  fun zoomTo(annoationIds : List<String>, padding : Float) {
    val map = this.googleMap ?: return
    if (annoationIds.size == 1) {
      val marker = markerIdLookup[annoationIds.first()] ?: return
      map.animateCamera(
          CameraUpdateFactory.newLatLngZoom(marker.position,
                                            18.toFloat()))
      return
    }
    val bounds = LatLngBounds.Builder()
    for (id in annoationIds) {
      val marker = markerIdLookup[id] ?: continue
      bounds.include(marker.position)
    }
    try {
      map.animateCamera(
          CameraUpdateFactory.newLatLngBounds(bounds.build(),
                                              padding.toInt()))
    } catch (e : Exception) {}
  }

  fun createMarkerForAnnotation(annotation: MapAnnotation, map: GoogleMap) : Marker {
    val marker : Marker
    if (annotation is ClusterAnnotation) {
      marker = map
          .addMarker(MarkerOptions()
                         .position(annotation.coordinate)
                         .title(annotation.title)
                         .icon(
                             BitmapDescriptorFactory.defaultMarker(
                                 annotation.colorHue)))
      marker.tag = annotation.identifier
    } else {
      marker = map
          .addMarker(MarkerOptions()
                         .position(annotation.coordinate)
                         .title(annotation.title)
                         .icon(
                             BitmapDescriptorFactory.defaultMarker(
                                 annotation.colorHue)))
      marker.tag = annotation.identifier
    }
    return marker
  }

  @SuppressLint("MissingPermission")
  override fun onRequestPermissionsResult(requestCode: Int,
                                          permissions: Array<out String>,
                                          grantResults: IntArray) {
    when(requestCode) {
      PermissionRequest -> {
        if ( grantResults[0] == PackageManager.PERMISSION_GRANTED ) {
          this.googleMap?.isMyLocationEnabled = true
          this.googleMap?.uiSettings?.isMyLocationButtonEnabled = true
        }
      }
      else -> super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }
  }

        OnMapReadyCallback {
    var googleMap: GoogleMap? = null
    var markerIdLookup = HashMap<String, Marker>()
    var polylineIdLookup = HashMap<String, Polyline>()
    var polygonIdLookup = HashMap<String, Polygon>()
    val PermissionRequest = 1

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.map_fragment)
        title = MapViewPlugin.mapTitle
        val mapFragment = supportFragmentManager.findFragmentById(
                R.id.map) as SupportMapFragment
        mapFragment.getMapAsync(this)
        if (MapViewPlugin.hideToolbar)
            this.supportActionBar?.hide()
        MapViewPlugin.mapActivity = this
    }

    @SuppressLint("MissingPermission")
    override fun onMapReady(map: GoogleMap) {
        googleMap = map
        map.setMapType(MapViewPlugin.mapViewType)
        map.uiSettings.isCompassEnabled = MapViewPlugin.showCompassButton
        if (MapViewPlugin.showUserLocation) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
                    != PackageManager.PERMISSION_GRANTED) {
                val array = arrayOf(Manifest.permission.ACCESS_FINE_LOCATION,
                        Manifest.permission.ACCESS_COARSE_LOCATION)
                ActivityCompat.requestPermissions(this, array, PermissionRequest)
            } else {
                map.isMyLocationEnabled = true
                map.uiSettings.isMyLocationButtonEnabled = MapViewPlugin.showMyLocationButton
            }
        }
        map.setOnMarkerDragListener(object : GoogleMap.OnMarkerDragListener {
            override fun onMarkerDragEnd(p0: Marker?) {
                if (p0 != null) {
                    val id: String = p0.tag as String
                    MapViewPlugin.annotationDragEnd(id, p0.position)
                }
            }

            override fun onMarkerDragStart(p0: Marker?) {
                if (p0 != null) {
                    val id: String = p0.tag as String
                    MapViewPlugin.annotationDragStart(id, p0.position)
                }
            }

            override fun onMarkerDrag(p0: Marker?) {
                if (p0 != null) {
                    val id: String = p0.tag as String
                    MapViewPlugin.annotationDrag(id, p0.position)
                }
            }
        })
        map.setOnMapClickListener { latLng ->
            MapViewPlugin.mapTapped(latLng)
        }
        map.setOnMarkerClickListener { marker ->
            MapViewPlugin.annotationTapped(marker.tag as String)
            false
        }
        map.setOnPolylineClickListener { polyline ->
            MapViewPlugin.polylineTapped(polyline.tag as String)
        }
        map.setOnPolygonClickListener { polygon ->
            MapViewPlugin.polygonTapped(polygon.tag as String)
        }
        map.setOnCameraMoveListener {
            val pos = map.cameraPosition
            MapViewPlugin.cameraPositionChanged(pos)
        }
        map.setOnMyLocationChangeListener {
            val loc = map.myLocation ?: return@setOnMyLocationChangeListener
            MapViewPlugin.locationDidUpdate(loc)
        }
        map.setOnInfoWindowClickListener { marker ->
            MapViewPlugin.infoWindowTapped(marker.tag as String)
        }
        map.moveCamera(CameraUpdateFactory.newCameraPosition(
                MapViewPlugin.initialCameraPosition))
        MapViewPlugin.onMapReady()
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        MapViewPlugin.toolbarActions.forEach {
            val item = menu.add(0, it.identifier, 0, it.title)
            item.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM)
        }
        return super.onCreateOptionsMenu(menu)
    }


    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        MapViewPlugin.handleToolbarAction(item.itemId)
        return true
    }

    override fun onDestroy() {
        super.onDestroy()
        MapViewPlugin.mapActivity = null
    }

    val zoomLevel: Float
        get() {
            return googleMap?.cameraPosition?.zoom ?: 0.0.toFloat()
        }

    val target: LatLng
        get() = googleMap?.cameraPosition?.target ?: LatLng(0.0,
                0.0)

    fun setCamera(target: LatLng, zoom: Float, bearing: Float, tilt: Float) {
        val cameraPosition = CameraPosition.Builder()
                .target(target)
                .zoom(zoom)
                .bearing(bearing)
                .tilt(tilt)
                .build()
        googleMap?.animateCamera(CameraUpdateFactory.newCameraPosition(cameraPosition))
    }

    fun setAnnotations(annotations: List<MapAnnotation>) {
        val map = this.googleMap ?: return
        clearMarkers()
        for (annotation in annotations) {
            val marker = createMarkerForAnnotation(annotation, map)
            markerIdLookup[annotation.identifier] = marker
        }
    }

    fun clearMarkers() {
        markerIdLookup.forEach {
            it.value.remove()
        }
        markerIdLookup.clear()
    }

    fun addMarker(annotation: MapAnnotation) {
        val map = this.googleMap ?: return
        val existingMarker = markerIdLookup[annotation.identifier]
        if (existingMarker != null) return
        val marker = createMarkerForAnnotation(annotation, map)
        markerIdLookup.put(annotation.identifier, marker)
    }

    fun removeMarker(annotation: MapAnnotation) {
        this.googleMap ?: return
        val existingMarker = markerIdLookup[annotation.identifier] ?: return
        markerIdLookup.remove(annotation.identifier)
        existingMarker.remove()
    }

    fun setPolylines(polyLines: List<MapPolyline>) {
        val map = this.googleMap ?: return
        clearPolylines()
        for (mapPolyline in polyLines) {
            val polyline = createPolyline(mapPolyline, map)
            polylineIdLookup[mapPolyline.identifier] = polyline
        }
    }

    fun clearPolylines() {
        polylineIdLookup.forEach {
            it.value.remove()
        }
        polylineIdLookup.clear()
    }

    fun addPolyline(mapPolyline: MapPolyline) {
        val map = this.googleMap ?: return
        val existingLine = polylineIdLookup[mapPolyline.identifier]
        if (existingLine != null) return
        val polyline = createPolyline(mapPolyline, map)
        polylineIdLookup.put(mapPolyline.identifier, polyline)
    }

    fun removePolyline(mapPolyline: MapPolyline) {
        this.googleMap ?: return
        val existingLine = polylineIdLookup[mapPolyline.identifier] ?: return
        polylineIdLookup.remove(mapPolyline.identifier)
        existingLine.remove()
    }

    fun setPolygons(mapPolygons: List<MapPolygon>) {
        val map = this.googleMap ?: return
        clearPolygons()
        for (mapPolygon in mapPolygons) {
            val polygon = createPolygon(mapPolygon, map)
            polygonIdLookup[mapPolygon.identifier] = polygon
        }
    }

    fun clearPolygons() {
        polygonIdLookup.forEach {
            it.value.remove()
        }
        polygonIdLookup.clear()
    }

    fun addPolygon(mapPolygon: MapPolygon) {
        val map = this.googleMap ?: return
        val existingFigure = polygonIdLookup[mapPolygon.identifier]
        if (existingFigure != null) return
        val polygon = createPolygon(mapPolygon, map)
        polygonIdLookup.put(mapPolygon.identifier, polygon)
    }

    fun removePolygon(mapPolygon: MapPolygon) {
        this.googleMap ?: return
        val existingFigure = polygonIdLookup[mapPolygon.identifier] ?: return
        polygonIdLookup.remove(mapPolygon.identifier)
        existingFigure.remove()
    }

    val visibleMarkers: List<String>
        get() {
            val map = this.googleMap ?: return emptyList()
            val region = map.projection.visibleRegion
            val visibleIds = ArrayList<String>()
            for (marker in markerIdLookup.values) {
                if (region.latLngBounds.contains(marker.position)) {
                    visibleIds.add(marker.tag as String)
                }
            }
            return visibleIds
        }

    val visiblePolyline: List<String>
        get() {
            val map = this.googleMap ?: return emptyList()
            val region = map.projection.visibleRegion
            val visibleIds = ArrayList<String>()
            for (polyline in polylineIdLookup.values) {
                for (point in polyline.points) {
                    if (region.latLngBounds.contains(point)) {
                        visibleIds.add(polyline.tag as String)
                        break
                    }
                }
            }
            return visibleIds
        }

    val visiblePolygon: List<String>
        get() {
            val map = this.googleMap ?: return emptyList()
            val region = map.projection.visibleRegion
            val visibleIds = ArrayList<String>()
            for (polygon in polygonIdLookup.values) {
                for (point in polygon.points) {
                    if (region.latLngBounds.contains(point)) {
                        visibleIds.add(polygon.tag as String)
                        break
                    }
                }
            }
            return visibleIds
        }


    fun zoomToFit(padding: Int) {
        val map = this.googleMap ?: return
        val bounds = LatLngBounds.Builder()
        var count = 0
        for (marker in markerIdLookup.values) {
            bounds.include(marker.position)
            count++
        }
        for (polyline in polylineIdLookup.values) {
            for (point in polyline.points) {
                bounds.include(point)
                count++
            }
        }
        for (polygon in polygonIdLookup.values) {
            for (point in polygon.points) {
                bounds.include(point)
                count++
            }
        }
        if (map.isMyLocationEnabled && map.myLocation != null) {
            if (count == 0) {
                map.animateCamera(CameraUpdateFactory.newLatLngZoom(
                        LatLng(map.myLocation.latitude,
                                map.myLocation.longitude), 12.toFloat()))
                return
            }
            bounds.include(LatLng(map.myLocation.latitude,
                    map.myLocation.longitude))
        }
        try {
            map.animateCamera(
                    CameraUpdateFactory.newLatLngBounds(bounds.build(), padding))
        } catch (e: Exception) {
        }
    }

    fun zoomToAnnotations(annoationIds: List<String>, padding: Float) {
        val map = this.googleMap ?: return
        if (annoationIds.size == 1) {
            val marker = markerIdLookup[annoationIds.first()] ?: return
            map.animateCamera(
                    CameraUpdateFactory.newLatLngZoom(marker.position,
                            18.toFloat()))
            return
        }
        val bounds = LatLngBounds.Builder()
        for (id in annoationIds) {
            val marker = markerIdLookup[id] ?: continue
            bounds.include(marker.position)
        }
        try {
            map.animateCamera(
                    CameraUpdateFactory.newLatLngBounds(bounds.build(),
                            padding.toInt()))
        } catch (e: Exception) {
        }
    }

    fun zoomToPolylines(polylineIds: List<String>, padding: Float) {
        val map = this.googleMap ?: return
        if (polylineIds.size == 1) {
            val polyline = polylineIdLookup[polylineIds.first()] ?: return
            map.animateCamera(
                    CameraUpdateFactory.newLatLngZoom(polyline.points.first(),
                            18.toFloat()))
            return
        }
        val bounds = LatLngBounds.Builder()
        for (id in polylineIds) {
            val polyline = polylineIdLookup[id] ?: continue
            for (point in polyline.points) {
                bounds.include(point)
            }
        }
        try {
            map.animateCamera(
                    CameraUpdateFactory.newLatLngBounds(bounds.build(),
                            padding.toInt()))
        } catch (e: Exception) {
        }
    }

    fun zoomToPolygons(polygonIds: List<String>, padding: Float) {
        val map = this.googleMap ?: return
        if (polygonIds.size == 1) {
            val polygon = polygonIdLookup[polygonIds.first()] ?: return
            map.animateCamera(
                    CameraUpdateFactory.newLatLngZoom(polygon.points.first(),
                            18.toFloat()))
            return
        }
        val bounds = LatLngBounds.Builder()
        for (id in polygonIds) {
            val polygon = polygonIdLookup[id] ?: continue
            for (point in polygon.points) {
                bounds.include(point)
            }
        }
        try {
            map.animateCamera(
                    CameraUpdateFactory.newLatLngBounds(bounds.build(),
                            padding.toInt()))
        } catch (e: Exception) {
        }
    }

    fun createMarkerForAnnotation(annotation: MapAnnotation, map: GoogleMap): Marker {
        val markerOptions = MarkerOptions()
                .position(annotation.coordinate)
                .title(annotation.title)
                .draggable(annotation.draggable)
                .rotation(annotation.rotation.toFloat())
        if (annotation is ClusterAnnotation) {
            markerOptions.snippet(annotation.clusterCount.toString())
        }
        var bitmap: Bitmap? = null
        if (annotation.icon != null) {
            try {
                val assetFileDescriptor: AssetFileDescriptor = MapViewPlugin.getAssetFileDecriptor(annotation.icon.asset)
                val fd = assetFileDescriptor.createInputStream()
                bitmap = BitmapFactory.decodeStream(fd)
                var width = annotation.icon.width
                var height = annotation.icon.height
                if (width == 0.0)
                    width = bitmap.width.toDouble()
                if (height == 0.0)
                    height = bitmap.height.toDouble()
                bitmap = Bitmap.createScaledBitmap(bitmap, width.toInt(), height.toInt(), false)
            } catch (exception: Exception) {
                exception.printStackTrace()
            }
        }
        if (bitmap != null) {
            markerOptions.icon(BitmapDescriptorFactory.fromBitmap(bitmap))
        } else {
            markerOptions.icon(BitmapDescriptorFactory.defaultMarker(
                    annotation.colorHue))
        }
        val marker = map.addMarker(markerOptions)
        marker.tag = annotation.identifier
        return marker
    }

    fun createPolyline(mapPolyline: MapPolyline, map: GoogleMap): Polyline {
        val polyline: Polyline = map
                .addPolyline(PolylineOptions()
                        .color(mapPolyline.color)
                        .visible(true)
                        .clickable(true)
                        .jointType(mapPolyline.jointType)
                        .width(mapPolyline.width)
                        .addAll(mapPolyline.points))
        polyline.tag = mapPolyline.identifier
        return polyline
    }

    fun createPolygon(mapPolygon: MapPolygon, map: GoogleMap): Polygon {
        val polygonOptions = PolygonOptions()
                .strokeColor(mapPolygon.strokeColor)
                .fillColor(mapPolygon.fillColor)
                .visible(true)
                .clickable(true)
                .strokeWidth(mapPolygon.strokeWidth)
                .strokeJointType(mapPolygon.jointType)
                .addAll(mapPolygon.points)
        if (mapPolygon.holes.isNotEmpty())
            for (hole in mapPolygon.holes) {
                polygonOptions.addHole(hole.points)
            }
        val polygon: Polygon = map.addPolygon(polygonOptions)
        polygon.tag = mapPolygon.identifier
        return polygon
    }

    @SuppressLint("MissingPermission")
    override fun onRequestPermissionsResult(requestCode: Int,
                                            permissions: Array<out String>,
                                            grantResults: IntArray) {
        when (requestCode) {
            PermissionRequest -> {
                if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    this.googleMap?.isMyLocationEnabled = true
                    this.googleMap?.uiSettings?.isMyLocationButtonEnabled = true
                }
            }
            else -> super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        }
    }
}