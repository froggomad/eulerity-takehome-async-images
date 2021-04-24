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
    
    private func decode<T: Decodable>(type: T.Type, from data: Data) throws -> T {
        let jsonDecoder = JSONDecoder()
        do {
            let instance = try jsonDecoder.decode(type.self, from: data)
            return instance
        } catch let decodeError {
            throw decodeError
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
            
            guard let response = response else {
                let error = NSError(domain: "\(#file).\(#function)",
                                    code: 999,
                                    userInfo: [NSLocalizedDescriptionKey: "invalid response"])
                
                print("invalid response in \(#function)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard response.statusCode < 400 else {
                let error = NSError(domain: "\(#file).\(#function)",
                                    code: 999,
                                    userInfo: [NSLocalizedDescriptionKey: "invalid response: \(response.statusCode), \(String(data: data ?? Data(), encoding: .utf8))"])
                
                print("invalid response code in \(#function): \(response.statusCode)")
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
            do {
                let imageArray = try self.decode(type: [EulerityImage].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(imageArray))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func getUploadLink(completion: @escaping (Result<URL?, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("upload")
        let request = URLRequest(url: url)
        URLSession.shared.loadData(using: request) { [unowned self] (data, response, error) in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let response = response else {
                let error = NSError(domain: "\(#file).\(#function)",
                                    code: 999,
                                    userInfo: [NSLocalizedDescriptionKey: "invalid response"])
                
                print("invalid response in \(#function)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard response.statusCode < 400 else {
                let error = NSError(domain: "\(#file).\(#function)",
                                    code: 999,
                                    userInfo: [NSLocalizedDescriptionKey: "invalid response: \(response.statusCode), \(String(data: data ?? Data(), encoding: .utf8))"])
                
                print("invalid response code in \(#function): \(response.statusCode)")
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
            
            do {
                let urlObject = try self.decode(type: EulerityImage.self, from: data)
                completion(.success(urlObject.url))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Storage Ops -
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
    
    func uploadImage(imageData: Data, completion: @escaping (Result<Void, Error>) -> Void = { _ in }) {
        getUploadLink { [unowned self] result in
            switch result {
            case .success(let url):
                guard let url = url else {
                    let error = NSError(domain: #function, code: 999, userInfo: [NSLocalizedDescriptionKey: "unable to get valid URL to upload file with"])
                    completion(.failure(error))
                    return
                }
                self.uploadImage(data: imageData, to: url, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - MultiPart Upload -
    private func uploadImage(data: Data, to url: URL, completion: @escaping (Result<Void, Error>) -> Void = { _ in }) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let uuidString = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(uuidString)", forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        
        let boundary = "Boundary-\(uuidString)"
        body.append(convertFileData(emailAddress: "kenny.dubroff@kennydubroff.com", originalUrl: url, mimeType: "image/jpeg", fileData: data, using: boundary))
        
        request.httpBody = body as Data
        
        URLSession.shared.loadData(using: request) { (data, response, error) in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let response = response else {
                let error = NSError(domain: "\(#file).\(#function)",
                                    code: 999,
                                    userInfo: [NSLocalizedDescriptionKey: "invalid response"])
                
                print("invalid response in \(#function)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard response.statusCode < 400 else {
                let error = NSError(domain: "\(#file).\(#function)",
                                    code: 999,
                                    userInfo: [NSLocalizedDescriptionKey: "invalid response: \(response.statusCode), \(String(data: data ?? Data(), encoding: .utf8) ?? "")\nRequest: \(NSString(string: String(data: request.httpBody!, encoding: .ascii)!))"])
                
                print("invalid response code in \(#function): \(response.statusCode)")
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
            print(data) // not sure what will come back here yet, if anything
            
        }
        
    }
    
    func convertFileData(emailAddress: String, originalUrl: URL, mimeType: String, fileData: Data, using boundary: String) -> Data {
        let data = NSMutableData()
        // TODO: clean this up using convertFormField?
        data.append(string: "--\(boundary)\r\n")
        data.append(string: "Content-Disposition: form-data; name=\"appid\"\r\n")
        data.append(string: emailAddress)
        data.append(string:"\r\n")
        
        data.append(string: "--\(boundary)\r\n")
        data.append(string: "Content-Disposition: form-data; name=\"original\"\r\n")
        data.append(string: originalUrl.absoluteString)
        data.append(string:"\r\n")
        
        data.append(string: "--\(boundary)\r\n")
        data.append(string: "Content-Disposition: form-data; name=\"file\"; filename=\"file.jpg\"\r\n") // ; filename=\"somefilename.jpg\"\r\n
        data.append(string: "Content-Type: \(mimeType)\r\n\r\n")
        
        data.append(fileData)
        data.append(string:"\r\n")
        data.append(string: "--\(boundary)--")
        return data as Data
    }
    
    private func convertFormField(named name: String, value: String, using boundary: String) -> String {
        let fieldString =
        """
        --\(boundary)
        Content-Disposition: form-data; name=\"\(name)\"

        \(value)
        
        """
        return fieldString
    }
    
}

extension NSMutableData {
    func append(string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
