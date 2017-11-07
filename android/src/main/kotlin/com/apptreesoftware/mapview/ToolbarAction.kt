package com.apptreesoftware.mapview

data class ToolbarAction(val title : String, val identifier: Int) {
    constructor(map: Map<String, Any>)
        : this(title = map["title"] as String,
               identifier = map["identifier"] as Int)
}