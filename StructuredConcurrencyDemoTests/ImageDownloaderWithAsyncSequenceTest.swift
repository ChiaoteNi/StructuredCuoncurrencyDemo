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

        let url = URL(string: "http://dummyURL.com")!
        let task = await sut.loadImage(with: url)

        let states = try await task.stream.reduce(into: [RemoteImageLoader.TaskStatus](), { partialResult, status in
            partialResult.append(status)
        })
        XCTAssertEqual(states.count, 12)
    }

    func testMultipleLoadImageTask() async throws {
        let session = MockURLSession(totalUnitCount: 10)
        let decoder = MockDecodeSucceedDecoder()
        sut = RemoteImageLoader(session: session, dataDecoder: decoder)

        async let task1 = sut.loadImage(with: URL(string: "http://someImage1.com")!)
        async let task2 = sut.loadImage(with: URL(string: "http://someImage2.com")!)

        let states1 = try await task1.stream.reduce(into: [RemoteImageLoader.TaskStatus](), { partialResult, status in
            partialResult.append(status)
        })
        let states2 = try await task2.stream.reduce(into: [RemoteImageLoader.TaskStatus](), { partialResult, status in
            partialResult.append(status)
        })

        XCTAssertEqual(states1.count, 12)
        XCTAssertEqual(states2.count, 12)
    }

    func testDuplicatedLoadImageTask() async throws {
        let session = MockURLSession(totalUnitCount: 10)
        let decoder = MockDecodeSucceedDecoder()
        sut = RemoteImageLoader(session: session, dataDecoder: decoder)

        let url = URL(string: "http://dummyURL.com")!
        async let task1 = await sut.loadImage(with: url)
        async let task2 = await sut.loadImage(with: url)

        let (downloadTask1, downloadTask2) = await(task1, task2)

        let states1 = try await downloadTask1.stream.reduce(into: [RemoteImageLoader.TaskStatus](), { partialResult, status in
            partialResult.append(status)
        })
        let states2 = try await downloadTask2.stream.reduce(into: [RemoteImageLoader.TaskStatus](), { partialResult, status in
            partialResult.append(status)
        })

        XCTAssert(downloadTask1 === downloadTask2)
        XCTAssertEqual(states1.count, 12)
        // Just like its name suggests, AsyncStream pops elements to us when we access it. This behavior makes sense, and means that we should not use it in the same way as the current implementation.
        XCTAssertEqual(states2.count, 0)
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
