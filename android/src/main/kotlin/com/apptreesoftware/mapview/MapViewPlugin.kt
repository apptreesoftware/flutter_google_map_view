package com.apptreesoftware.mapview

import android.app.Activity
import android.content.Intent
import android.content.res.AssetFileDescriptor
import android.location.Location
import android.os.Build
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
/*
Every time i reformatted the code, this imports were removed so i put them here
for easier access.

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
 */
class MapViewPlugin(val activity: Activity) : MethodCallHandler {
    val mapTypeMapping: HashMap<String, Int> = hashMapOf(
            "none" to GoogleMap.MAP_TYPE_NONE,
            "normal" to GoogleMap.MAP_TYPE_NORMAL,
            "satellite" to GoogleMap.MAP_TYPE_SATELLITE,
            "terrain" to GoogleMap.MAP_TYPE_TERRAIN,
            "hybrid" to GoogleMap.MAP_TYPE_HYBRID
    )

    companion object {
        lateinit var channel: MethodChannel
        var toolbarActions: List<ToolbarAction> = emptyList()
        var showUserLocation: Boolean = false
        var showMyLocationButton: Boolean = false
        var showCompassButton: Boolean = false
        var hideToolbar: Boolean = false
        var mapTitle: String = ""
        lateinit var initialCameraPosition: CameraPosition
        var mapActivity: MapActivity? = null
        val REQUEST_GOOGLE_PLAY_SERVICES = 1000
        var mapViewType: Int = GoogleMap.MAP_TYPE_NORMAL
        lateinit var registrar: Registrar

        @JvmStatic
        fun registerWith(registrar: Registrar): Unit {
            channel = MethodChannel(registrar.messenger(), "com.apptreesoftware.map_view")
            val plugin = MapViewPlugin(activity = registrar.activity())
            channel.setMethodCallHandler(plugin)
            this.registrar = registrar
        }

        fun handleToolbarAction(id: Int) {
            channel.invokeMethod("onToolbarAction", id)
        }

        fun onMapReady() {
            channel.invokeMethod("onMapReady", null)
        }

        fun getToolbarActions(actionsList: List<Map<String, Any>>?): List<ToolbarAction> {
            if (actionsList == null) return emptyList()
            val actions = ArrayList<ToolbarAction>()
            actionsList.mapTo(actions) { ToolbarAction(it) }
            return actions
        }

        fun getCameraPosition(map: Map<String, Any>): CameraPosition {
            val latitude = map["latitude"] as Double
            val longitude = map["longitude"] as Double
            val zoom = map["zoom"] as Double
            return CameraPosition(LatLng(latitude, longitude), zoom.toFloat(), 0.0f, 0.0f)
        }

        fun mapTapped(latLng: LatLng) {
            this.channel.invokeMethod("mapTapped",
                    mapOf("latitude" to latLng.latitude,
                            "longitude" to latLng.longitude))
        }

        fun annotationTapped(id: String) {
            this.channel.invokeMethod("annotationTapped", id)
        }

        fun annotationDragStart(id: String, latLng: LatLng) {
            this.channel.invokeMethod("annotationDragStart", mapOf(
                    "id" to id,
                    "latitude" to latLng.latitude,
                    "longitude" to latLng.longitude
            ))
        }

        fun annotationDragEnd(id: String, latLng: LatLng) {
            this.channel.invokeMethod("annotationDragEnd", mapOf(
                    "id" to id,
                    "latitude" to latLng.latitude,
                    "longitude" to latLng.longitude
            ))
        }

        fun annotationDrag(id: String, latLng: LatLng) {
            this.channel.invokeMethod("annotationDrag", mapOf(
                    "id" to id,
                    "latitude" to latLng.latitude,
                    "longitude" to latLng.longitude
            ))
        }

        fun polylineTapped(id: String) {
            this.channel.invokeMethod("polylineTapped", id)
        }

        fun polygonTapped(id: String) {
            this.channel.invokeMethod("polygonTapped", id)
        }

        fun cameraPositionChanged(pos: CameraPosition) {
            this.channel.invokeMethod("cameraPositionChanged", mapOf(
                    "latitude" to pos.target.latitude,
                    "longitude" to pos.target.longitude,
                    "zoom" to pos.zoom,
                    "bearing" to pos.bearing,
                    "tilt" to pos.tilt
            ))
        }

        fun locationDidUpdate(loc: Location) {
            var verticalAccuracy = 0.0f
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                verticalAccuracy = loc.verticalAccuracyMeters
            this.channel.invokeMethod("locationUpdated", mapOf(
                    "latitude" to loc.latitude,
                    "longitude" to loc.longitude,
                    "time" to loc.time,
                    "altitude" to loc.altitude,
                    "speed" to loc.speed,
                    "bearing" to loc.bearing,
                    "horizontalAccuracy" to loc.accuracy,
                    "verticalAccuracy" to verticalAccuracy
            ))
        }

        fun infoWindowTapped(id: String) {
            this.channel.invokeMethod("infoWindowTapped", id)
        }

        fun onBackButtonTapped() {
            this.channel.invokeMethod("backButtonTapped", null)
        }

        fun getAssetFileDecriptor(asset: String): AssetFileDescriptor {
            val assetManager = registrar.context().getAssets()
            val key = registrar.lookupKeyForAsset(asset)
            return assetManager.openFd(key)
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result): Unit {
        when {
            call.method == "setApiKey" -> result.success(false)
            call.method == "show" -> {
                val code = GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(activity)
                if (GoogleApiAvailability.getInstance().showErrorDialogFragment(activity, code, REQUEST_GOOGLE_PLAY_SERVICES)) {
                    return
                }
                val mapOptions = call.argument<Map<String, Any>>("mapOptions")
                val cameraDict = mapOptions["cameraPosition"] as Map<String, Any>
                initialCameraPosition = getCameraPosition(cameraDict)
                toolbarActions = getToolbarActions(call.argument<List<Map<String, Any>>>("actions"))
                showUserLocation = mapOptions["showUserLocation"] as Boolean
                showMyLocationButton = mapOptions["showMyLocationButton"] as Boolean
                showCompassButton = mapOptions["showCompassButton"] as Boolean
                hideToolbar = mapOptions["hideToolbar"] as Boolean
                mapTitle = mapOptions["title"] as String

                if (mapOptions["mapViewType"] != null) {
                    val mappedMapType: Int? = mapTypeMapping.get(mapOptions["mapViewType"]);
                    if (mappedMapType != null) mapViewType = mappedMapType;
                }

                val intent = Intent(activity, MapActivity::class.java)
                activity.startActivity(intent)
                result.success(true)
                return
            }
            call.method == "dismiss" -> {
                mapActivity?.finish()
                result.success(true)
                return
            }
            call.method == "getZoomLevel" -> {
                val zoom = mapActivity?.zoomLevel ?: 0.0.toFloat()
                result.success(zoom)
            }
            call.method == "getCenter" -> {
                val center = mapActivity?.target ?: LatLng(0.0, 0.0)
                result.success(mapOf("latitude" to center.latitude,
                        "longitude" to center.longitude))
            }
            call.method == "setCamera" -> {
                handleSetCamera(call.arguments as Map<String, Any>)
                result.success(true)
            }
            call.method == "zoomToAnnotations" -> {
                handleZoomToAnnotations(call.arguments as Map<String, Any>)
                result.success(true)
            }
            call.method == "zoomToPolylines" -> {
                handleZoomToPolylines(call.arguments as Map<String, Any>)
                result.success(true)
            }
            call.method == "zoomToPolygons" -> {
                handleZoomToPolygons(call.arguments as Map<String, Any>)
                result.success(true)
            }
            call.method == "zoomToFit" -> {
                mapActivity?.zoomToFit(call.arguments as Int)
                result.success(true)
            }
            call.method == "getVisibleMarkers" -> {
                val visibleMarkerIds = mapActivity?.visibleMarkers ?: emptyList()
                result.success(visibleMarkerIds)
            }
            call.method == "clearAnnotations" -> {
                mapActivity?.clearMarkers()
                result.success(true)
            }
            call.method == "setAnnotations" -> {
                handleSetAnnotations(call.arguments as List<Map<String, Any>>)
                result.success(true)
            }
            call.method == "addAnnotation" -> {
                handleAddAnnotation(call.arguments as Map<String, Any>)
            }
            call.method == "removeAnnotation" -> {
                handleRemoveAnnotation(call.arguments as Map<String, Any>)
            }
            call.method == "getVisiblePolylines" -> {
                val visiblePolylineIds = mapActivity?.visiblePolyline ?: emptyList()
                result.success(visiblePolylineIds)
            }
            call.method == "clearPolylines" -> {
                mapActivity?.clearPolylines()
                result.success(true)
            }
            call.method == "setPolylines" -> {
                handleSetPolylines(call.arguments as List<Map<String, Any>>)
                result.success(true)
            }
            call.method == "addPolyline" -> {
                handleAddPolyline(call.arguments as Map<String, Any>)
            }
            call.method == "removePolyline" -> {
                handleRemovePolyline(call.arguments as Map<String, Any>)
            }
            call.method == "getVisiblePolygons" -> {
                val visiblePolygonIds = mapActivity?.visiblePolygon ?: emptyList()
                result.success(visiblePolygonIds)
            }
            call.method == "clearPolygons" -> {
                mapActivity?.clearPolygons()
                result.success(true)
            }
            call.method == "setPolygons" -> {
                handleSetPolygons(call.arguments as List<Map<String, Any>>)
                result.success(true)
            }
            call.method == "addPolygon" -> {
                handleAddPolygon(call.arguments as Map<String, Any>)
            }
            call.method == "removePolygon" -> {
                handleRemovePolygon(call.arguments as Map<String, Any>)
            }
            else -> result.notImplemented()
        }
    }

    fun handleSetCamera(map: Map<String, Any>) {
        val lat = map["latitude"] as Double
        val lng = map["longitude"] as Double
        val zoom = map["zoom"] as Double
        val bearing = map["bearing"] as Double
        val tilt = map["tilt"] as Double
        mapActivity?.setCamera(LatLng(lat, lng), zoom.toFloat(), bearing.toFloat(), tilt.toFloat())
    }

    fun handleZoomToAnnotations(map: Map<String, Any>) {
        val ids = map["annotations"] as List<String>
        val padding = map["padding"] as Double
        mapActivity?.zoomToAnnotations(ids, padding.toFloat())
    }

    fun handleZoomToPolylines(map: Map<String, Any>) {
        val ids = map["polylines"] as List<String>
        val padding = map["padding"] as Double
        mapActivity?.zoomToPolylines(ids, padding.toFloat())
    }

    fun handleZoomToPolygons(map: Map<String, Any>) {
        val ids = map["polygons"] as List<String>
        val padding = map["padding"] as Double
        mapActivity?.zoomToPolygons(ids, padding.toFloat())
    }

    fun handleSetAnnotations(annotations: List<Map<String, Any>>) {
        val mapAnnoations = ArrayList<MapAnnotation>()
        for (a in annotations) {
            val mapAnnotation = MapAnnotation.fromMap(a)
            if (mapAnnotation != null) {
                mapAnnoations.add(mapAnnotation)
            }
        }
        mapActivity?.setAnnotations(mapAnnoations)
    }

    fun handleAddAnnotation(map: Map<String, Any>) {
        MapAnnotation.fromMap(map)?.let {
            mapActivity?.addMarker(it)
        }
    }

    fun handleRemoveAnnotation(map: Map<String, Any>) {
        MapAnnotation.fromMap(map)?.let {
            mapActivity?.removeMarker(it)
        }
    }

    fun handleSetPolylines(polylines: List<Map<String, Any>>) {
        val mapPolylines = ArrayList<MapPolyline>()
        for (a in polylines) {
            val mapPolyline = MapPolyline.fromMap(a)
            if (mapPolyline != null) {
                mapPolylines.add(mapPolyline)
            }
        }
        mapActivity?.setPolylines(mapPolylines)
    }

    fun handleAddPolyline(map: Map<String, Any>) {
        MapPolyline.fromMap(map)?.let {
            mapActivity?.addPolyline(it)
        }
    }

    fun handleRemovePolyline(map: Map<String, Any>) {
        MapPolyline.fromMap(map)?.let {
            mapActivity?.removePolyline(it)
        }
    }

    fun handleSetPolygons(polygons: List<Map<String, Any>>) {
        val mapPolygons = ArrayList<MapPolygon>()
        for (a in polygons) {
            val mapPolygon = MapPolygon.fromMap(a)
            if (mapPolygon != null) {
                mapPolygons.add(mapPolygon)
            }
        }
        mapActivity?.setPolygons(mapPolygons)
    }

    fun handleAddPolygon(map: Map<String, Any>) {
        MapPolygon.fromMap(map)?.let {
            mapActivity?.addPolygon(it)
        }
    }

    fun handleRemovePolygon(map: Map<String, Any>) {
        MapPolygon.fromMap(map)?.let {
            mapActivity?.removePolygon(it)
        }
    }
}

