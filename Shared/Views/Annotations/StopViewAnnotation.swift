//
//  StopViewAnnotation.swift
//  iOS
//
//  Created by Douglas Taquary on 19/07/20.
//

import UIKit
import MapKit

public class StopViewAnnotation: MKAnnotationView {
    override public var annotation: MKAnnotation? {
        willSet {
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            let imageName = "figure.wave.circle.fill"
            image = UIImage(systemName: imageName)?
                        .colored(.systemPink)

        }
    }
}
