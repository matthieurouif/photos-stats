//
//  ColorExtension.swift
//  Photo Stats
//
//  Created by Matthieu Rouif on 22/09/2015.
//  Copyright © 2015 As-App. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(rgb: UInt, a:CGFloat) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: a
        )
    }
    
    convenience init(rgb: UInt) {
        self.init(rgb: rgb, a:1.0)
    }
}

