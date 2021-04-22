//
//  EulerityImageController.swift
//  Eulerity Async Images
//
//  Created by Kenneth Dubroff on 4/22/21.
//

import UIKit

class EulerityImageController {
    /// url: imageData
    private let imageCache = Cache<URL, Data>()
    
    private let baseURL = URL(string: "https://eulerity-hackathon.appspot.com")!
    
    private func decode<T: Decodable>(type: T.Type, from data: Data) -> T? {
        let jsonDecoder = JSONDecoder()
        do {
            let instance = try jsonDecoder.decode(type.self, from: data)
            return instance
        } catch let decodeError {
            print(decodeError)
            return nil
        }
    }
    
    func getImageMetaData(completion: @escaping (Result<[EulerityImage]?, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("image")
        let request = URLRequest(url: url)
        URLSession.shared.loadData(using: request) { [unowned self] data, response, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    completion(.failure(error!))
                }
                return
            }
            
            guard let response = response,
                  response.statusCode < 400 else {
                let error = NSError(domain: "\(#file).\(#function)",
                                    code: 999,
                                    userInfo: [NSLocalizedDescriptionKey: "invalid response"])
                
                print("invalid response in \(#function)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "\(#file).\(#function)",
                                    code: response.statusCode,
                                    userInfo: [NSLocalizedDescriptionKey: "No Data Received: \(response.statusCode)"])
                
                print("no data received in \(#function)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            let imageArray = self.decode(type: [EulerityImage].self, from: data)
            DispatchQueue.main.async {
                completion(.success(imageArray))
            }
        }
    }
    
    func getUploadLink(completion: @escaping (Result<UIImage?, Error>) -> Void) {
        
    }
    
    func cacheImageData(_ data: Data, for url: URL) {
        imageCache.cache(value: data, for: url)
    }
    
    func getImage(for url: URL) -> UIImage? {
        guard let data = imageCache.value(for: url) else {
            return nil
        }
        
        guard let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
    
}
