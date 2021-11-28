//
//  TripMapView.swift
//  iOS
//
//  Created by Douglas Taquary on 28/11/21.
//

import SwiftUI
import MapKit

struct TripMapView: View {
    
    @ObservedObject var viewModel = TripMapViewModel()
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(center: TripMapViewModel.defaultCoordinate, span: TripMapViewModel.defaultSpan)
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: viewModel.allAnnotations)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            self.viewModel.locationManager.requestAlwaysAuthorization()
            self.viewModel.locationManager.requestWhenInUseAuthorization()
            self.viewModel.positions()
        }
    }

}

struct TripMapView_Previews: PreviewProvider {
    static var previews: some View {
        TripMapView()
    }
}
