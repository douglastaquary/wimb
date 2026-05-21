//
//  SearchView.swift
//  WhereIsMyBus
//

import SwiftUI

struct SearchBarView: View {

    @Binding var searchText: String
    @State private var showCancelButton = false
    var onCommit: () -> Void = {}

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")

                ZStack(alignment: .leading) {
                    if searchText.isEmpty {
                        Text(WIMBL10n.searchPlaceholder)
                    }
                    TextField("", text: $searchText, onEditingChanged: { isEditing in
                        showCancelButton = isEditing
                    }, onCommit: onCommit)
                    .foregroundColor(.primary)
                }

                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .opacity(searchText.isEmpty ? 0 : 1)
                }
            }
            .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
            .foregroundColor(.secondary)
            .background(Color(.tertiarySystemFill))
            .cornerRadius(10)

            if showCancelButton {
                Button(WIMBL10n.searchCancel) {
                    UIApplication.shared.endEditing()
                    searchText = ""
                    showCancelButton = false
                }
                .foregroundColor(Color(.systemBlue))
            }
        }
        .padding(.horizontal)
    }
}
