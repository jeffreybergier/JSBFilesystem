//
//  NSFileCoordinator_ReadMethod_NormOp_tests.swift
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/29/18.
//

import XCTest
import JSBFilesystem

class NSFileCoordinator_ReadDataMethod_NormOp_tests: XCTestCase {

    var directory: URL!
    let fileName = UUID().uuidString + ".testfile"
    let ogData = Data(UUID().uuidString.utf8)

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

    func testNSFCReadData() {
        do {
            let fileURL = self.directory.appendingPathComponent(fileName)
            let testData = try NSFileCoordinator.JSBFS_readData(from: fileURL, filePresenter: nil)
            XCTAssertNotNil(testData)
            XCTAssert(self.ogData == testData)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }
}

class NSFileCoordinator_ReadFileWrapperMethod_NormOp_tests: XCTestCase {

    var directory: URL!
    let fileName = UUID().uuidString + ".testfile"
    let ogData = Data(UUID().uuidString.utf8)
    lazy var ogFileWrapper: FileWrapper = FileWrapper(regularFileWithContents: self.ogData)

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

    func testNSFCReadData() {
        do {
            let fileURL = self.directory.appendingPathComponent(fileName)
            let testWrapper = try NSFileCoordinator.JSBFS_readFileWrapper(from: fileURL, filePresenter: nil)
            XCTAssertNotNil(testWrapper.regularFileContents)
            XCTAssert(self.ogData == testWrapper.regularFileContents!)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }
}
