//
//  ViewController.swift
//  JustPhotoPickerExample
//
//  Created by Igor Belov on 16.07.2021.
//

import UIKit
import JustPhotoPicker

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        var config = JustPhotoPickerConfiguration()
        config.accentColor = .systemPink
        config.selectionLimit = 2
        config.isSelectionRequired = true
        config.overlayTintColor = .systemPurple
        let photoPicker = JustPhotoPicker(configuration: config)
        photoPicker.didFinishPicking = { images, canceled in
            if canceled {
                print("Did not select any images")
                return
            }

            print("Selected \(images.count) images")
        }
        self.present(photoPicker, animated: true, completion: nil)
    }
}
