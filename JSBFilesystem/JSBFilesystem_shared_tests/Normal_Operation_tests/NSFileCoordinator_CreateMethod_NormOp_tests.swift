//
//  NSFileCoordinator_Op_tests.swift
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/29/18.
//

import XCTest
import JSBFilesystem

class NSFileCoordinator_CreateMethod_NormOp_tests: XCTestCase {

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
    }

    override func tearDown() {
        try! FileManager.default.removeItem(at: self.directory)
    }

    func testNSFCNormOpWriteData() {
        do {
            let fileURL = self.directory.appendingPathComponent(self.fileName)
            XCTAssertNil(try? Data(contentsOf: fileURL))
            try NSFileCoordinator.JSBFS_write(self.ogData, to: fileURL, filePresenter: nil)
            let testData = try Data(contentsOf: fileURL)
            XCTAssertNotNil(testData)
            XCTAssert(self.ogData == testData)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }

    func testNSFCNormOpWriteFileWrapper() {
        do {
            let fileURL = self.directory.appendingPathComponent(self.fileName)
            XCTAssertNil(try? Data(contentsOf: fileURL))
            try NSFileCoordinator.JSBFS_write(self.ogFileWrapper, to: fileURL, filePresenter: nil)
            let testWrapper = try FileWrapper(url: fileURL, options: .immediate)
            XCTAssertNotNil(testWrapper.regularFileContents)
            XCTAssert(self.ogData == testWrapper.regularFileContents!)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }

    func testNFSCNormOpCreateDirectory() {
        do {
            let dirURL = self.directory.appendingPathComponent(self.fileName)
            try NSFileCoordinator.JSBFS_createDirectory(at: dirURL, filePresenter: nil)
            var isDirectory: ObjCBool = false
            let isExisting = FileManager.default.fileExists(atPath: dirURL.path,
                                                            isDirectory: &isDirectory)
            XCTAssert(isExisting)
            XCTAssert(isDirectory.boolValue)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }

    func testNFSCNormOpCheckExistingDirectory() {
        do {
            let dirURL = self.directory.appendingPathComponent(self.fileName)
            XCTAssertFalse(FileManager.default.fileExists(atPath: dirURL.path,
                                                          isDirectory: nil))
            try FileManager.default.createDirectory(at: dirURL,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
            let check = try NSFileCoordinator.JSBFS_fileExistsAndIsDirectory(at: dirURL,
                                                                             filePresenter: nil)
            XCTAssertNotNil(check)
            XCTAssert(check.value1)
            XCTAssert(check.value2)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }

    func testNFSCNormOpCheckExistingFile() {
        do {
            let dirURL = self.directory.appendingPathComponent(self.fileName)
            XCTAssertFalse(FileManager.default.fileExists(atPath: dirURL.path,
                                                          isDirectory: nil))
            try self.ogData.write(to: dirURL)
            let check = try NSFileCoordinator.JSBFS_fileExistsAndIsDirectory(at: dirURL,
                                                                             filePresenter: nil)
            XCTAssertNotNil(check)
            XCTAssert(check.value1)
            XCTAssertFalse(check.value2)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }

    func testNSFCNormOpCheckNonExistingFile() {
        do {
            let dirURL = self.directory.appendingPathComponent(self.fileName)
            XCTAssertFalse(FileManager.default.fileExists(atPath: dirURL.path,
                                                          isDirectory: nil))
            let check = try NSFileCoordinator.JSBFS_fileExistsAndIsDirectory(at: dirURL,
                                                                             filePresenter: nil)
            XCTAssertNotNil(check)
            XCTAssertFalse(check.value1)
            XCTAssertFalse(check.value2)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }

    func testNSFCNormOpExecuteBlock() {
        do {
            let expectation = XCTestExpectation(description: "")
            try NSFileCoordinator.JSBFS_execute({ expectation.fulfill() },
                                                whileCoordinatingAccessAt: self.directory,
                                                filePresenter: nil)
            XCTWaiter().wait(for: [expectation], timeout: 0.1)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }

}
