//
//  JSBFSDirectory_MethodErrorPropogation_tests.swift
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/28/18.
//

import XCTest
import JSBFilesystem

class JSBFSDirectory_MethodErrorPropogation_tests: XCTestCase {

    let validRemoteURL = URL(string: "http://www.apple.com")!
    var directory: JSBFSDirectory!

    override func setUp() {
        self.directory = try! JSBFSDirectory(base: .cachesDirectory,
                                             appendingPathComponent: UUID().uuidString,
                                             createIfNeeded: true,
                                             sortedBy: .nameAFirst,
                                             filteredBy: nil)
        // delete the directory out from under our object
        // that way its methods will produce errors
        try! FileManager.default.removeItem(at: self.directory.url)
    }

    func testJSBFSDirContentsCountErrorPropogation() {
        do {
            let _ = try self.directory.contentsCount()
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == NSCocoaErrorDomain)
            XCTAssert(error.code == 260)
        }
    }

    func testJSBFSDirURLAtIndexErrorPropogation() {
        do {
            let _ = try self.directory.url(at: 5)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == NSCocoaErrorDomain)
            XCTAssert(error.code == 260)
        }
    }

    func testJSBFSDirDeleteContentsErrorPropogation() {
        do {
            let _ = try self.directory.deleteContents()
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == NSCocoaErrorDomain)
            XCTAssert(error.code == 260)
        }
    }

    func testJSBFSDirIndexOfURLErrorPropogation() {
        do {
            let _ = try self.directory.indexOfItem(with: self.validRemoteURL)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == NSCocoaErrorDomain)
            XCTAssert(error.code == 260)
        }
    }
}
