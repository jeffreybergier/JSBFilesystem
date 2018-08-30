//
//  JSBFSDirectory_Init_NormOp_tests.swift
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/29/18.
//

import XCTest
import JSBFilesystem

class JSBFSDirectory_Init_NormOp_tests: XCTestCase {

    let precalculatedURL: URL = {
        let lastPathComponent = UUID().uuidString
        let cachesURL = FileManager.default.urls(for: .cachesDirectory,
                                                 in: .userDomainMask).first!
        let precalculatedURL = cachesURL.appendingPathComponent(lastPathComponent)
        return precalculatedURL
    }()

    override func tearDown() {
        try? FileManager.default.removeItem(at: precalculatedURL)
    }

    func testDirectoryBaseInitDirectoryCreate() {
        do {
            let directory = try JSBFSDirectory(base: .cachesDirectory,
                                               appendingPathComponent: UUID().uuidString,
                                               createIfNeeded: true,
                                               sortedBy: .nameAFirst,
                                               filteredBy: nil)
            var isDirectory: ObjCBool = false
            let isExisting = FileManager.default.fileExists(atPath: directory.url.path,
                                                            isDirectory: &isDirectory)
            XCTAssert(isDirectory.boolValue)
            XCTAssert(isExisting)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }

    func testDirectoryBaseInitNoDirectoryCreate() {
        do {
            let _ = try JSBFSDirectory(base: .cachesDirectory,
                                       appendingPathComponent: UUID().uuidString,
                                       createIfNeeded: false,
                                       sortedBy: .nameAFirst,
                                       filteredBy: nil)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == kJSBFSErrorDomain)
            XCTAssert(JSBFSErrorCode(rawValue: error.code)! == .directoryNotFoundAndNotCreated)
        }
    }

    func testDirectoryBaseInitFileConflictExistsCreate() {
        do {
            let data = Data("".utf8)
            try data.write(to: precalculatedURL, options: .atomic)
            let _ = try JSBFSDirectory(base: .cachesDirectory,
                                       appendingPathComponent: self.precalculatedURL.lastPathComponent,
                                       createIfNeeded: false,
                                       sortedBy: .nameAFirst,
                                       filteredBy: nil)
            let _ = try JSBFSDirectory(base: .cachesDirectory,
                                       appendingPathComponent: self.precalculatedURL.lastPathComponent,
                                       createIfNeeded: true,
                                       sortedBy: .nameAFirst,
                                       filteredBy: nil)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == kJSBFSErrorDomain)
            XCTAssert(JSBFSErrorCode(rawValue: error.code)! == .specifiedURLIsFileExpectedDirectory)
        }
    }

    func testDirectoryURLInitDirectoryCreate() {
        do {
            let directory = try JSBFSDirectory(directoryURL: self.precalculatedURL,
                                               createIfNeeded: true,
                                               sortedBy: .nameAFirst,
                                               filteredBy: nil)
            var isDirectory: ObjCBool = false
            let isExisting = FileManager.default.fileExists(atPath: directory.url.path,
                                                            isDirectory: &isDirectory)
            XCTAssert(isDirectory.boolValue)
            XCTAssert(isExisting)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }

    func testDirectoryURLInitNoDirectoryCreate() {
        do {
            let _ = try JSBFSDirectory(directoryURL: self.precalculatedURL,
                                       createIfNeeded: false,
                                       sortedBy: .nameAFirst,
                                       filteredBy: nil)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == kJSBFSErrorDomain)
            XCTAssert(JSBFSErrorCode(rawValue: error.code)! == .directoryNotFoundAndNotCreated)
        }
    }

    func testDirectoryURLInitFileConflictExistsCreate() {
        do {
            let data = Data("".utf8)
            try data.write(to: precalculatedURL, options: .atomic)
            let _ = try JSBFSDirectory(directoryURL: self.precalculatedURL,
                                       createIfNeeded: false,
                                       sortedBy: .nameAFirst,
                                       filteredBy: nil)
            let _ = try JSBFSDirectory(directoryURL: self.precalculatedURL,
                                       createIfNeeded: true,
                                       sortedBy: .nameAFirst,
                                       filteredBy: nil)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == kJSBFSErrorDomain)
            XCTAssert(JSBFSErrorCode(rawValue: error.code)! == .specifiedURLIsFileExpectedDirectory)
        }
    }

}
