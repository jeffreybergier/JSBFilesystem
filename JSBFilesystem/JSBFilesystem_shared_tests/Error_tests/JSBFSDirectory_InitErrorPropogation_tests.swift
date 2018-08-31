//
//  JSBFSDirectory_ErrorPropogation_tests.swift
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
