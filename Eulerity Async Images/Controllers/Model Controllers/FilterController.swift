//
//  FilterController.swift
//  Eulerity Async Images
//
//  Created by Kenneth Dubroff on 4/23/21.
//

import UIKit

enum FilterName: CaseIterable {
    static var allCases: [FilterName] = [
        .sepia(intensity: 1.0),
        .vignette(inputRadius: 5, inputIntensity: 1.0),
        .invertColors,
        .blur(radius: 5)
    ]
    
    case sepia(intensity: Double)
    case vignette(inputRadius: Double, inputIntensity: Double)
    case invertColors
    case blur(radius: Double)
    
    var friendlyName: String {
        switch self {
        case .sepia:
            return "Sepia"
        case .vignette:
            return "Vignette"
        case .invertColors:
            return "Invert Colors"
        case .blur:
            return "Blur"
        }
    }
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
            let vignetteFilter = CIFilter(name: "CIVignette")!
            vignetteFilter.setValue(inputRadius, forKey: kCIInputRadiusKey)
            vignetteFilter.setValue(intensity, forKey: kCIInputIntensityKey)
            currentFilter = vignetteFilter
            
        case .invertColors:
            currentFilter = CIFilter(name: "CIColorInvert")!
            
        case let .blur(radius):
            let filter = CIFilter(name: "CIGaussianBlur")!
            filter.setValue(radius, forKey: kCIInputRadiusKey)
            currentFilter = filter
        }
        
        currentFilter.setValue(ciImage, forKey: kCIInputImageKey)
        self.filter = currentFilter
    }
}
