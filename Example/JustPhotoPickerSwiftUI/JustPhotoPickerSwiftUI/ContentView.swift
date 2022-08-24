//
//  ContentView.swift
//  JustPhotoPickerSwiftUI
//
//  Created by Igor Belov on 24.08.2022.
//

import SwiftUI
import JustPhotoPicker

struct ContentView: View {
    @State private var showingPicker: Bool = false

    private var pickerConfig: JustPhotoPickerConfiguration {
        var config = JustPhotoPickerConfiguration()
        config.accentColor = .systemPink
        config.selectionLimit = 2
        config.isSelectionRequired = true
        config.overlayTintColor = .systemPurple
        return config
    }

    var body: some View {
        VStack {
            Button("Select photo") {
                showingPicker = true
            }
        }
        .sheet(isPresented: $showingPicker) {
            JustPhotoPickerView(configuration: pickerConfig)
                .onFinish { images in
                    print("Selected \(images.count) images")
                }
                .onCancel {
                    print("Did not select any images")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
