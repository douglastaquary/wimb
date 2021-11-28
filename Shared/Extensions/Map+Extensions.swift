//
//  Map+Extensions.swift
//  iOS
//
//  Created by Douglas Taquary on 28/11/21.
//

import SwiftUI
import MapKit

extension Map {

    init<Items>(
        coordinateRegion: Binding<MKCoordinateRegion>,
        interactionModes: MapInteractionModes = .all,
        showsUserLocation: Bool = false,
        userTrackingMode: Binding<MapUserTrackingMode>? = nil,
        annotationItems: Items
    ) where Content == _DefaultAnnotatedMapContent<Items>,
        Items: RandomAccessCollection,
        Items.Element == AnyMapAnnotationItem
    {
        self.init(
            coordinateRegion: coordinateRegion,
            interactionModes: interactionModes,
            showsUserLocation: showsUserLocation,
            userTrackingMode: userTrackingMode,
            annotationItems: annotationItems,
            annotationContent: { $0.annotation }
        )
    }

    init<Items>(
        mapRect: Binding<MKMapRect>,
        interactionModes: MapInteractionModes = .all,
        showsUserLocation: Bool = false,
        userTrackingMode: Binding<MapUserTrackingMode>? = nil,
        annotationItems: Items
    ) where Content == _DefaultAnnotatedMapContent<Items>,
        Items: RandomAccessCollection,
        Items.Element == AnyMapAnnotationItem
    {
        self.init(
            mapRect: mapRect,
            interactionModes: interactionModes,
            showsUserLocation: showsUserLocation,
            userTrackingMode: userTrackingMode,
            annotationItems: annotationItems,
            annotationContent: { $0.annotation }
        )
    }
}
