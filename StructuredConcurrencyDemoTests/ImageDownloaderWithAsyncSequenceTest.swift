//
//  ImageDownloaderWithAsyncSequenceTest.swift
//  StructuredConcurrencyDemoTests
//
//  Created by Chiaote Ni on 2023/3/27.
//

import XCTest
@testable import StructuredConcurrencyDemo

final class ImageDownloaderWithAsyncSequenceTest: XCTestCase {

    var sut: RemoteImageLoader!

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testLoadImage() async throws {
        let session = MockURLSession(totalUnitCount: 10)
        let decoder = MockDecodeSucceedDecoder()
        sut = RemoteImageLoader(session: session, dataDecoder: decoder)
        let expectation = XCTestExpectation()

        let url = URL(string: "http://dummyURL.com")!
        sut.loadImage(
            with: url,
            progressHandler: { _ in },
            then: { result in
                switch result {
                case .success:
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
            })
        XCTWaiter().wait(for: [expectation], timeout: 5)
    }

    func testMultipleLoadImageTask() async throws {
    }

    func testDuplicatedLoadImageTask() async throws {
    }
}

extension ImageDownloaderWithAsyncSequenceTest {

    class MockDecodeSucceedDecoder: ImageDataDecoding {
        func decode(data: Data) -> UIImage? {
            UIImage()
        }
    }

    class MockURLSession: URLSession {
        var willTheTaskSucceed: Bool
        var totalUnitCount: Int64

        init(willTheTaskSucceed: Bool = true, totalUnitCount: Int64 = 10) {
            self.willTheTaskSucceed = willTheTaskSucceed
            self.totalUnitCount = totalUnitCount
        }

        override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            let dataTask = URLSessionDataTask()
            dataTask.progress.totalUnitCount = totalUnitCount
            let totalUnitCount = totalUnitCount
            let willTheTaskSucceed = willTheTaskSucceed

            Task.detached {
                for i in 0 ... totalUnitCount {
                    dataTask.progress.completedUnitCount = i
                    try? await Task.sleep(nanoseconds: 250_000_000)
                }
                if willTheTaskSucceed {
                    let data = Data()
                    completionHandler(data, nil, nil)
                } else {
                    let error = NSError(domain: "dummyError", code: 0)
                    completionHandler(nil, nil, error)
                }
            }
            return dataTask
        }
    }
}
