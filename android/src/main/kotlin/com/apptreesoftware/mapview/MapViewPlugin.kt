package com.apptreesoftware.mapview

import android.app.Activity
import android.content.Intent
import android.location.Location
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import com.google.android.gms.maps.GoogleMap


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
        var mapTitle : String = ""
        lateinit var initialCameraPosition: CameraPosition
        var mapActivity: MapActivity? = null
        val REQUEST_GOOGLE_PLAY_SERVICES = 1000
        var mapViewType: Int = GoogleMap.MAP_TYPE_NORMAL

        @JvmStatic
        fun registerWith(registrar: Registrar): Unit {
            channel = MethodChannel(registrar.messenger(), "com.apptreesoftware.map_view")
            val plugin = MapViewPlugin(activity = registrar.activity())
            channel.setMethodCallHandler(plugin)
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

        fun cameraPositionChanged(pos: CameraPosition) {
            this.channel.invokeMethod("cameraPositionChanged", mapOf(
                "latitude" to pos.target.latitude,
                "longitude" to pos.target.longitude,
                "zoom" to pos.zoom
            ))
        }

        fun locationDidUpdate(loc: Location) {
            this.channel.invokeMethod("locationUpdated", mapOf(
                "latitude" to loc.latitude,
                "longitude" to loc.longitude
            ))
        }

        fun infoWindowTapped(id: String) {
            this.channel.invokeMethod("infoWindowTapped", id)
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
                mapTitle = mapOptions["title"] as String

                if (mapOptions["mapViewType"] != null) {
                    var mappedMapType: Int? = mapTypeMapping.get(mapOptions["mapViewType"]);
                    if (mappedMapType != null) mapViewType = mappedMapType as Int;
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
            call.method == "zoomToFit" -> {
                mapActivity?.zoomToAnnotations(call.arguments as Int)
                result.success(true)
            }
            call.method == "getVisibleMarkers" -> {
                val visibleMarkerIds = mapActivity?.visibleMarkers ?: emptyList()
                result.success(visibleMarkerIds)
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
            else -> result.notImplemented()
        }
    }

    fun handleSetCamera(map: Map<String, Any>) {
        val lat = map["latitude"] as Double
        val lng = map["longitude"] as Double
        val zoom = map["zoom"] as Double
        mapActivity?.setCamera(LatLng(lat, lng), zoom.toFloat())
    }

    fun handleZoomToAnnotations(map: Map<String, Any>) {
        val ids = map["annotations"] as List<String>
        val padding = map["padding"] as Double
        mapActivity?.zoomTo(annoationIds = ids, padding = padding.toFloat())
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
}

