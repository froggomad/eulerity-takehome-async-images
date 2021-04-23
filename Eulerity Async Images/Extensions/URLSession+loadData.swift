//
//  URLSession+loadData.swift
//  Eulerity Async Images
//
//  Created by Kenneth Dubroff on 4/22/21.
//
import Foundation

extension URLSession {
    /// convenience method to always use.resume and provide default error handling
    func loadData(using request: URLRequest, with completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        self.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Networking error with \(String(describing: request.url?.absoluteString)) \n\(error)")
                // could return here if we want to return from errors in the default implementation
            }
            
            completion(data, response as? HTTPURLResponse, error)
        }.resume()
    }
}
