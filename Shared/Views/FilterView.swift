//
//  FilterView.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 13/07/20.
//

import SwiftUI

struct FilterView: View {
    
    @Binding var searchText: String
    @Binding var navigationTitleHidden: Bool
    @Binding var showingCancelButton: Bool
    
    var body: some View {
        HStack(alignment: .center) {
            HStack {
                SFSymbols.magnifyingglass
                    .foregroundColor(.secondary)
                    .font(.headline)
                TextField("Buscar por uma linha", text: self.$searchText)
            }
            .padding(5)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.leading)
            .padding(.trailing, !showingCancelButton ? 10 : 0)
            .padding(.bottom)
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        withAnimation {
                            self.navigationTitleHidden = true
                            self.showingCancelButton = true
                        }
                }
            )
            if showingCancelButton {
                Button(action: {
                    withAnimation {
                        UIApplication.shared.endEditing()
                        self.searchText = ""
                        self.navigationTitleHidden = false
                        self.showingCancelButton = false
                    }
                }) {
                    Text("Cancelar").foregroundColor(.green)
                }
                .padding(.trailing)
                .padding(.bottom)
            }
        }
        
    }
}


struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(searchText: .constant(""), navigationTitleHidden: .constant(true), showingCancelButton: .constant(false))
            .previewLayout(.sizeThatFits)
    }
}


struct TimerView: View {
    @State private var timeRemaining = 10
//    var timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)

    //let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Text("\(timeRemaining)")
        }
//        .onReceive(timer) { _ in
//            if self.timeRemaining > 0 {
//                self.timeRemaining -= 1
//            }
//        }
    }
    
    
    func update() {
        if self.timeRemaining > 0 {
            self.timeRemaining -= 1
        }
    }
}


struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
