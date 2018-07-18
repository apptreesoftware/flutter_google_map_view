package com.apptreesoftware.mapview

import android.graphics.Color
import com.google.android.gms.maps.model.LatLng

open class MapAnnotation(val identifier: String, val title: String, val coordinate: LatLng, val rotation: Double,
                         val icon: MarkerIcon?, val color: Int, val draggable: Boolean) {
    companion object {
        fun fromMap(map: Map<String, Any>): MapAnnotation? {
            val type = map["type"] as String? ?: return null
            val identifier = map["id"] as String
            val latitude = map["latitude"] as Double
            val longitude = map["longitude"] as Double
            val rotation = map["rotation"] as Double
            val title = map["title"] as String
            var icon: MarkerIcon? = null
            if (map.containsKey("markerIcon"))
                icon = MarkerIcon.fromMap(map["markerIcon"] as Map<String, Any>)
            val colorMap = map["color"] as Map<String, Int>
            val color = colorFromMap(colorMap)
            val draggable = map["draggable"] as Boolean
            if (type == "cluster") {
                val clusterCount = map["clusterCount"] as Int
                return ClusterAnnotation(identifier, title, LatLng(latitude, longitude), rotation, icon, color, draggable,
                        clusterCount)
            }
            return MapAnnotation(identifier, title, LatLng(latitude, longitude), rotation, icon, color, draggable)
        }
    }

    val colorHue: Float
        get() {
            val hsv = FloatArray(3)
            Color.colorToHSV(this.color, hsv)
            return hsv[0]
        }
}

class ClusterAnnotation(identifier: String,
                        title: String,
                        coordinate: LatLng,
                        rotation: Double,
                        icon: MarkerIcon?,
                        color: Int,
                        draggable: Boolean,
                        val clusterCount: Int) : MapAnnotation(identifier, title, coordinate, rotation, icon, color, draggable)

fun colorFromMap(map: Map<String, Int>): Int {
    val r = map["r"] ?: 0
    val g = map["g"] ?: 0
    val b = map["b"] ?: 0
    val a = map["a"] ?: 0
    return Color.argb(a, r, g, b)
}

class MarkerIcon(val asset: String, val width: Double, val height: Double) {
    companion object {
        fun fromMap(map: Map<String, Any>): MarkerIcon {
            val asset = map["asset"] as String
            val width = map["width"] as Double
            val height = map["height"] as Double
            return MarkerIcon(asset, width, height)
        }
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is MarkerIcon) return false

        if (asset != other.asset) return false
        if (width != other.width) return false
        if (height != other.height) return false

        return true
    }

    override fun hashCode(): Int {
        var result = asset.hashCode()
        result = 31 * result + width.hashCode()
        result = 31 * result + height.hashCode()
        return result
    }

    override fun toString(): String {
        return "MarkerIcon(asset='$asset', width=$width, height=$height)"
    }
}