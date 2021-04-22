//
//  UIView+Images.swift
//  Eulerity Async Images
//
//  Created by Kenneth Dubroff on 4/22/21.
//

import UIKit

enum CustomImage: String {
    case photo = "photoIcon"
    case camera = "cameraIcon"
    
    var img: UIImage {
        return UIImage(named: self.rawValue)!
    }
}
