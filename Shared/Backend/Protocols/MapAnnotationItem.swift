//
//  MapAnnotationItem.swift
//  iOS
//
//  Created by Douglas Taquary on 28/11/21.
//

import SwiftUI
import MapKit

protocol MapAnnotationItem: Identifiable {
    associatedtype Annotation: MapAnnotationProtocol

    var coordinate: CLLocationCoordinate2D { get }
    var annotation: Annotation { get }
}

struct AnyMapAnnotationItem: MapAnnotationItem {
    let id: AnyHashable
    let coordinate: CLLocationCoordinate2D
    let annotation: AnyMapAnnotation
    let base: Any

    init<T: MapAnnotationItem>(_ base: T) {
        self.id = base.id
        self.coordinate = base.coordinate
        self.annotation = AnyMapAnnotation(base.annotation)
        self.base = base
    }
}


struct AnyMapAnnotation: MapAnnotationProtocol {
    let _annotationData: _MapAnnotationData
    let base: Any

    init<T: MapAnnotationProtocol>(_ base: T) {
        self._annotationData = base._annotationData
        self.base = base
    }
}
