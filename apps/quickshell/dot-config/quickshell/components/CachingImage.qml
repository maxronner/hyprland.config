// components/CachingImage.qml
// Async cached image wrapper. Converts file path string to Image source.
import QtQuick

Image {
    id: root

    property string path: ""

    source: path !== "" ? "file://" + path : ""
    asynchronous: true
    cache: true
    fillMode: Image.PreserveAspectCrop
}
