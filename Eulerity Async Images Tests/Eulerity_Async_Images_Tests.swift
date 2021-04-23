//
//  Eulerity_Async_Images_Tests.swift
//  Eulerity Async Images Tests
//
//  Created by Kenneth Dubroff on 4/22/21.
//
@testable import Eulerity_Async_Images

import XCTest

class Eulerity_Async_Images_Tests: XCTestCase {

    func testGettingMetaData(completion: @escaping (URL?) -> Void) {
        let expectation = self.expectation(description: "Get Image Metadata")
        
        let imageController = EulerityImageController()
        
        imageController.getImageMetaData { result in
            switch result {
            case .success(let imageData):
                XCTAssertNotNil(imageData)
                completion(imageData?[0].url)
            case .failure(let error):
                XCTFail(error.localizedDescription)
                completion(nil)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testGettingImage() {
        let expectation = self.expectation(description: "get image from url")
        testGettingMetaData { (url) in
            XCTAssertNotNil(url)
            let imageController = EulerityImageController()
            let fetchOp = PhotoFetchOperation(url: url!, imageController: imageController)
            let cacheOp = BlockOperation {
                if let data = fetchOp.imageData {
                    imageController.cacheImageData(data, for: url!)
                }
            }
            // can't cache unless we fetch first
            cacheOp.addDependency(fetchOp)
            
            let queue = OperationQueue()
            
            queue.addOperations ([
                fetchOp,
                cacheOp
            ], waitUntilFinished: false)
            
            let imageSetOp = BlockOperation {
                XCTAssertNotNil(fetchOp.imageData)
                XCTAssertNotNil(UIImage(data: fetchOp.imageData!))
                expectation.fulfill()
            }
            // need to fetch before we can set
            imageSetOp.addDependency(fetchOp)
            
            OperationQueue.current?.addOperation(imageSetOp)
        }
        wait(for: [expectation], timeout: 10)
    }

}
