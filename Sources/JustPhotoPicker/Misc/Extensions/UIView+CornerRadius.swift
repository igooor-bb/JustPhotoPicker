//
//  UIView+CornerRadius.swift
//  PhotoPicker
//
//  Created by Igor Belov on 11.07.2021.
//

import UIKit

extension UIView {
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}
