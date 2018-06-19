package com.apptreesoftware.mapview

import android.graphics.Color
import android.util.Log
import com.google.android.gms.maps.model.JointType
import com.google.android.gms.maps.model.LatLng

open class MapPolyline(val identifier: String, val points: ArrayList<LatLng>, val width: Float,
                       val color: Int, val jointType: Int) {
    companion object {
        fun fromMap(map: Map<String, Any>): MapPolyline? {
            val identifier = map["id"] as String
            val pointsList = arrayListOf<LatLng>();
            val pointsParam = map["points"] as ArrayList<Map<String, Any>>
            pointsParam.forEach {
                val latitude: Double = it["latitude"] as Double
                val longitude: Double = it["longitude"] as Double
                pointsList.add(LatLng(latitude, longitude))
            }
            val colorMap = map["color"] as Map<String, Int>
            val width = map["width"] as Double
            val jointType = map["jointType"] as Int
            val color = colorFromMap(colorMap)
            return MapPolyline(identifier, pointsList, width.toFloat(), color, jointType)
        }
    }

    val colorHue: Float
        get() {
            val hsv = FloatArray(3)
            Color.colorToHSV(this.color, hsv)
            return hsv[0]
        }
}

