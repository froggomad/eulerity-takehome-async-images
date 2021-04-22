//
//  Eulerity_Async_Images_Tests.swift
//  Eulerity Async Images Tests
//
//  Created by Kenneth Dubroff on 4/22/21.
//
@testable import Eulerity_Async_Images

import XCTest

class Eulerity_Async_Images_Tests: XCTestCase {

    func testGettingMetaData() {
        let expectation = self.expectation(description: "Get Image Metadata")
        
        let imageController = EulerityImageController()
        
        imageController.getImageMetaData { result in
            expectation.fulfill()
            switch result {
            case .success(let imageData):
                XCTAssertNotNil(imageData)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        wait(for: [expectation], timeout: 10)
    }

}
