//
//  JSBFSDirectory_MethodErrorPropogation_tests.swift
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/28/18.
//
//  MIT License
//
//  Copyright (c) 2018 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
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
