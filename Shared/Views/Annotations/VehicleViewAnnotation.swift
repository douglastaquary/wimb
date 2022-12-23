//
//  VehicleViewAnnotation.swift
//  iOS
//
//  Created by Douglas Taquary on 19/07/20.
//

import Foundation
import MapKit

public class VehicleViewAnnotation: MKAnnotationView {
    override public var annotation: MKAnnotation? {
        willSet {
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

            backgroundColor = .tertiarySystemBackground
            guard let annotation = newValue as? VehicleAnnotation else { return }
            image = UIImage.init(systemName: annotation.pinCustomImageName)
        }
    }
}



import UIKit
import MapKit

class VehicleAnnotation: MKPointAnnotation {
    public var pinCustomImageName: String = "bus.fill"
    var courseDegrees : Double = 0.0 // Change The Value for Rotating Bus Image Position
}

extension UIImage {

    func colored(_ color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            self.draw(at: .zero)
            context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height), blendMode: .sourceAtop)
        }
    }

}
