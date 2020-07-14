//
//  ClearButton.swift
//  WhereIsMyBus
//
//  Created by Douglas Taquary on 13/07/20.
//

import SwiftUI

struct ClearButton: ViewModifier {
    @Binding var text: String
    
    public func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content
            if !text.isEmpty {
                Button(action: { self.text = "" }) {
                    SFSymbols.deleteCircle
                        .foregroundColor(Color(UIColor.opaqueSeparator))
                        .padding(8)
                }
            }
        }
    }
}
