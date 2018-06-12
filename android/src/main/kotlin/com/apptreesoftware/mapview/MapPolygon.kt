package com.apptreesoftware.mapview

import com.google.android.gms.maps.model.LatLng

open class MapPolygon(val identifier: String, val points: ArrayList<LatLng>, val holes: ArrayList<Hole>, val strokeWidth: Float,
                      val fillColor: Int, val strokeColor: Int, val jointType: Int) {
    companion object {
        fun fromMap(map: Map<String, Any>): MapPolygon? {
            val identifier = map["id"] as String
            val pointsList = arrayListOf<LatLng>();
            val holesList = arrayListOf<Hole>();
            val pointsParam = map["points"] as ArrayList<Map<String, Any>>
            pointsParam.forEach {
                val latitude: Double = it["latitude"] as Double
                val longitude: Double = it["longitude"] as Double
                pointsList.add(LatLng(latitude, longitude))
            }
            val holesParam = map["holes"] as ArrayList<Map<String, Map<String, Any>>>
            for (hole in holesParam) {
                val holePointsMap = hole["points"] as ArrayList<Map<String, Any>>
                val holePoints = arrayListOf<LatLng>()
                holePointsMap.forEach {
                    val latitude: Double = it["latitude"] as Double
                    val longitude: Double = it["longitude"] as Double
                    holePoints.add(LatLng(latitude, longitude))
                }
                if (holePoints.isNotEmpty())
                    holesList.add(Hole(holePoints))
            }
            val fillColorMap = map["fillColor"] as Map<String, Int>
            val strokeColorMap = map["strokeColor"] as Map<String, Int>
            val strokeWidth = map["strokeWidth"] as Double
            val fillColor = colorFromMap(fillColorMap)
            val strokeColor = colorFromMap(strokeColorMap)
            val jointType = map["jointType"] as Int
            return MapPolygon(identifier, pointsList, holesList, strokeWidth.toFloat(), fillColor, strokeColor, jointType)
        }
    }
}

class Hole(val points: ArrayList<LatLng>)

