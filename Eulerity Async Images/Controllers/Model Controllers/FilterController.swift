//
//  FilterController.swift
//  Eulerity Async Images
//
//  Created by Kenneth Dubroff on 4/23/21.
//

import UIKit

enum FilterName {
    case sepia(intensity: Double)
    case vignette(inputRadius: Double, inputIntensity: Double)
    case invertColors
    case blur(value: Double)
}

class FilterController {
    var filter: CIFilter?
    var image: UIImage
    
    var ciImage: CIImage? {
        return CIImage(image: image)
    }
    
    init(image: UIImage, filter: FilterName) {
        self.image = image
        setFilter(filter)
    }
    
    func filterImage() -> UIImage? {
        guard let filter = filter,
              let ciImage = filter.outputImage
        else { return nil }
        
        // one liner:
        // return filter?.outputImage != nil ? UIImage(ciImage: filter!.outputImage!) : nil
        
        return UIImage(ciImage: ciImage)
    }
    
    private func setFilter(_ filter: FilterName) {
        var currentFilter: CIFilter
        
        switch filter {
        case let .sepia(intensity):
            let sepiaFilter = CIFilter(name:"CISepiaTone")!
            sepiaFilter.setValue(intensity, forKey: kCIInputIntensityKey)
            currentFilter = sepiaFilter
            
        case let .vignette(inputRadius, intensity):
            let vignetteFilter = CIFilter(name: "")!
            vignetteFilter.setValue(inputRadius, forKey: kCIInputRadiusKey)
            vignetteFilter.setValue(intensity, forKey: kCIInputIntensityKey)
            currentFilter = vignetteFilter
            
        case .invertColors:
            currentFilter = CIFilter(name: "CIColorInvert")!
            
        case let .blur(value):
            let filter = CIFilter(name: "CIGaussianBlur")!
            filter.setValue(value, forKey: kCIInputRadiusKey)
            currentFilter = filter
        }
        
        currentFilter.setValue(ciImage, forKey: kCIInputImageKey)
        self.filter = currentFilter
    }
}
