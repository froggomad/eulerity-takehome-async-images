//
//  EulerityImageController.swift
//  Eulerity Async Images
//
//  Created by Kenneth Dubroff on 4/22/21.
//

import UIKit

class EulerityImageController {
    /// row: image
    var imageCache: [Int: UIImage] = [:]
    
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
                completion(.failure(error!))
                return
            }
            
            guard let response = response,
                  response.statusCode < 400 else {
                let error = NSError(domain: "\(#file).\(#function)",
                                    code: response?.statusCode ?? 999,
                                    userInfo: [NSLocalizedDescriptionKey: "invalid response: \(response?.statusCode ?? 999)"])
                
                completion(.failure(error))
                print("invalid response in \(#function): \(response?.statusCode ?? 999)")
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "\(#file).\(#function)",
                                    code: response.statusCode,
                                    userInfo: [NSLocalizedDescriptionKey: "No Data Received: \(response.statusCode)"])
                
                completion(.failure(error))
                print("no data received in \(#function)")
                return
            }
            
            let imageArray = self.decode(type: [EulerityImage].self, from: data)
            completion(.success(imageArray))
        }
    }
    
    func getImage(from url: URL, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        
    }
    
    func getUploadLink(completion: @escaping (Result<UIImage?, Error>) -> Void) {
        
    }
    
}
