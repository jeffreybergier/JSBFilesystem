//
//  NSFileCoordinator_TransformMethod_NormOp_tests.swift
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/31/18.
//

import XCTest
import JSBFilesystem

class NSFileCoordinator_TransformDataMethod_NormOp_tests: XCTestCase {

    var directory: URL!
    let fileName = UUID().uuidString + ".testfile"
    let ogData = Data(UUID().uuidString.utf8)
    let newData = Data(UUID().uuidString.utf8)

    override func setUp() {
        let fm = FileManager.default
        self.directory = fm.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!.appendingPathComponent(UUID().uuidString)
        try! fm.createDirectory(at: self.directory,
                                withIntermediateDirectories: true,
                                attributes: nil)
        let fileURL = self.directory.appendingPathComponent(fileName)
        try! self.ogData.write(to: fileURL)
    }

    override func tearDown() {
        try! FileManager.default.removeItem(at: self.directory)
    }

    func testNSFCTransformData() {
        do {
            let fileURL = self.directory.appendingPathComponent(fileName)
            try NSFileCoordinator.JSBFS_readAndWriteData(at: fileURL, afterTransforming:
            { testData -> Data in
                XCTAssertNotNil(testData)
                XCTAssert(self.ogData == testData)
                return self.newData
            }, filePresenter: nil)
            let transformedData = try Data(contentsOf: fileURL)
            XCTAssertNotNil(transformedData)
            XCTAssert(self.newData == transformedData)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }
}

class NSFileCoordinator_TransformFileWrapperMethod_NormOp_tests: XCTestCase {

    var directory: URL!
    let fileName = UUID().uuidString + ".testfile"
    let ogData = Data(UUID().uuidString.utf8)
    let newData = Data(UUID().uuidString.utf8)
    lazy var ogFileWrapper: FileWrapper = FileWrapper(regularFileWithContents: self.ogData)
    lazy var newFileWrapper: FileWrapper = FileWrapper(regularFileWithContents: self.newData)

    override func setUp() {
        let fm = FileManager.default
        self.directory = fm.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!.appendingPathComponent(UUID().uuidString)
        try! fm.createDirectory(at: self.directory,
                                withIntermediateDirectories: true,
                                attributes: nil)
        let fileURL = self.directory.appendingPathComponent(fileName)
        try! self.ogFileWrapper.write(to: fileURL, options: .atomic, originalContentsURL: nil)
    }

    override func tearDown() {
        try! FileManager.default.removeItem(at: self.directory)
    }

    func testNSFCTransformFileWrapper() {
        do {
            let fileURL = self.directory.appendingPathComponent(fileName)
            try NSFileCoordinator.JSBFS_readAndWriteFileWrapper(at: fileURL, afterTransforming:
            { testFileWrapper -> FileWrapper in
                XCTAssertNotNil(testFileWrapper.regularFileContents)
                XCTAssert(self.ogData == testFileWrapper.regularFileContents!)
                return self.newFileWrapper
            }, filePresenter: nil)
            let transformedFileWrapper = try FileWrapper(url: fileURL, options: .immediate)
            XCTAssertNotNil(transformedFileWrapper.regularFileContents)
            XCTAssert(self.newData == transformedFileWrapper.regularFileContents!)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }
}
