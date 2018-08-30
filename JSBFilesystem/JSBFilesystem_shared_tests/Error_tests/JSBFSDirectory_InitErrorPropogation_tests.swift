//
//  JSBFSDirectory_ErrorPropogation_tests.swift
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/28/18.
//

import XCTest
import JSBFilesystem

class JSBFSDirectory_InitErrorPropogation_tests: XCTestCase {

    let invalidLocalURL = URL(string: "file:///\(UUID().uuidString)")!
    let validRemoteURL = URL(string: "http://www.apple.com")!
    let existingFileURL: URL = {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return base.appendingPathComponent(UUID().uuidString + "/file.txt")
    }()

    override func setUp() {
        let data = "A File".data(using: .utf8)!
        try! FileManager.default.createDirectory(at: self.existingFileURL.deletingLastPathComponent(),
                                            withIntermediateDirectories: true,
                                            attributes: nil)
        try! data.write(to: self.existingFileURL)
    }

    override func tearDown() {
        try! FileManager.default.removeItem(at: self.existingFileURL.deletingLastPathComponent())
    }

    func testJSBFSDirURLInitErrorPropagation() {
        do {
            _ = try JSBFSDirectory(directoryURL: self.invalidLocalURL,
                                   createIfNeeded: true,
                                   sortedBy: JSBFSDirectorySort.nameAFirst,
                                   filteredBy: nil)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == NSCocoaErrorDomain)
            XCTAssert(error.code == 513)
        }
        do {
            _ = try JSBFSDirectory(directoryURL: self.invalidLocalURL,
                                   createIfNeeded: false,
                                   sortedBy: JSBFSDirectorySort.nameAFirst,
                                   filteredBy: nil)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == kJSBFSErrorDomain)
            XCTAssert(JSBFSErrorCode(rawValue: error.code)! == .directoryNotFoundAndNotCreated)
        }
        do {
            _ = try JSBFSDirectory(directoryURL: self.existingFileURL,
                                   createIfNeeded: false,
                                   sortedBy: JSBFSDirectorySort.nameAFirst,
                                   filteredBy: nil)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == kJSBFSErrorDomain)
            XCTAssert(JSBFSErrorCode(rawValue: error.code)! == .specifiedURLIsFileExpectedDirectory)
        }
    }
    
    func testJSBFSDirBaseInitErrorPropagation() {
        do {
            _ = try JSBFSDirectory(base: FileManager.SearchPathDirectory.cachesDirectory,
                                   appendingPathComponent: UUID().uuidString,
                                   createIfNeeded: false,
                                   sortedBy: JSBFSDirectorySort.nameAFirst,
                                   filteredBy: nil)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == kJSBFSErrorDomain)
            XCTAssert(JSBFSErrorCode(rawValue: error.code)! == .directoryNotFoundAndNotCreated)
        }
    }
}
