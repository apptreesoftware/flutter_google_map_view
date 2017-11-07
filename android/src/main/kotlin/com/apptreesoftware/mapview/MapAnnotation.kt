package com.apptreesoftware.mapview

import android.graphics.Color
import com.google.android.gms.maps.model.LatLng

open class MapAnnotation(val identifier: String, val title: String, val coordinate: LatLng,
                         val color: Int) {
    companion object {
        fun fromMap(map: Map<String, Any>): MapAnnotation? {
            val type = map["type"] as String? ?: return null
            val identifier = map["id"] as String
            val latitude = map["latitude"] as Double
            val longitude = map["longitude"] as Double
            val title = map["title"] as String
            val colorMap = map["color"] as Map<String, Int>
            val color = colorFromMap(colorMap)
            if (type == "cluster") {
                val clusterCount = map["clusterCount"] as Int
                return ClusterAnnotation(identifier, title, LatLng(latitude, longitude), color,
                                         clusterCount)
            }
            return MapAnnotation(identifier, title, LatLng(latitude, longitude), color)
        }
    }

    val colorHue: Float get() {
        val hsv = FloatArray(3)
        Color.colorToHSV(this.color, hsv)
        return hsv[0]
    }
}

class ClusterAnnotation(identifier: String,
                        title: String,
                        coordinate: LatLng,
                        color: Int,
                        val clusterCount: Int) : MapAnnotation(identifier, title, coordinate, color)

fun colorFromMap(map: Map<String, Int>): Int {
    val r = map["r"] ?: 0
    val g = map["g"] ?: 0
    val b = map["b"] ?: 0
    val a = map["a"] ?: 0
    return Color.argb(a, r, g, b)
}