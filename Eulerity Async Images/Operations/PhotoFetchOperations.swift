//
//  PhotoFetchOperations.swift
//  Eulerity Async Images
//
//  Created by Kenneth Dubroff on 4/22/21.
//

import Foundation

class PhotoFetchOperation: ConcurrentOperation {
    
    // MARK: - Properties
    private let queue = DispatchQueue(label: "PhotoFetchQueue")
    private var dataTask: URLSessionDataTask?
    private var imageController: EulerityImageController
    
    var imageData: Data?
    let url: URL
    
    init(url: URL, imageController: EulerityImageController) {
        self.url = url
        self.imageController = imageController
        super.init()
    }
    
    override func start() {
        state = .isExecuting
        fetchPhoto()
        dataTask?.resume()
    }
    
    override func cancel() {
        state = .isFinished
        dataTask?.cancel()
    }
    
    func fetchPhoto() {
        dataTask = URLSession.shared.dataTask(with: url) { [unowned self] (data, _, error) in
            defer {
                self.state = .isFinished
            }
            if let error = error {
                print(error)
                return
            }
            guard let data = data else {
                print("No data")
                return
            }
            self.queue.sync {
                self.imageData = data
            }
        }
    }
}


