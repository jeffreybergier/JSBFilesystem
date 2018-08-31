//
//  JSBFSDirectory_Init_NormOp_tests.swift
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/29/18.
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

class JSBFSObservedDirectory_Init_NormOp_tests: XCTestCase {

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

    func testObservedDirectoryBaseInitDirectoryCreate() {
        do {
            let directory = try JSBFSObservedDirectory(base: .cachesDirectory,
                                                       appendingPathComponent: UUID().uuidString,
                                                       createIfNeeded: true,
                                                       sortedBy: .nameAFirst,
                                                       filteredBy: nil,
                                                       changeKind: .modificationsAsInsertionsDeletions)
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

    func testObservedDirectoryBaseInitNoDirectoryCreate() {
        do {
            let _ = try JSBFSObservedDirectory(base: .cachesDirectory,
                                               appendingPathComponent: UUID().uuidString,
                                               createIfNeeded: false,
                                               sortedBy: .nameAFirst,
                                               filteredBy: nil,
                                               changeKind: .modificationsAsInsertionsDeletions)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == kJSBFSErrorDomain)
            XCTAssert(JSBFSErrorCode(rawValue: error.code)! == .directoryNotFoundAndNotCreated)
        }
    }

    func testObservedDirectoryBaseInitFileConflictExistsCreate() {
        do {
            let data = Data("".utf8)
            try data.write(to: precalculatedURL, options: .atomic)
            let _ = try JSBFSObservedDirectory(base: .cachesDirectory,
                                               appendingPathComponent: self.precalculatedURL.lastPathComponent,
                                               createIfNeeded: false,
                                               sortedBy: .nameAFirst,
                                               filteredBy: nil,
                                               changeKind: .modificationsAsInsertionsDeletions)
            let _ = try JSBFSObservedDirectory(base: .cachesDirectory,
                                               appendingPathComponent: self.precalculatedURL.lastPathComponent,
                                               createIfNeeded: true,
                                               sortedBy: .nameAFirst,
                                               filteredBy: nil,
                                               changeKind: .modificationsAsInsertionsDeletions)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == kJSBFSErrorDomain)
            XCTAssert(JSBFSErrorCode(rawValue: error.code)! == .specifiedURLIsFileExpectedDirectory)
        }
    }

    func testObservedDirectoryURLInitDirectoryCreate() {
        do {
            let directory = try JSBFSObservedDirectory(directoryURL: self.precalculatedURL,
                                                       createIfNeeded: true,
                                                       sortedBy: .nameAFirst,
                                                       filteredBy: nil,
                                                       changeKind: .modificationsAsInsertionsDeletions)
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

    func testObservedDirectoryURLInitNoDirectoryCreate() {
        do {
            let _ = try JSBFSObservedDirectory(directoryURL: self.precalculatedURL,
                                               createIfNeeded: false,
                                               sortedBy: .nameAFirst,
                                               filteredBy: nil,
                                               changeKind: .modificationsAsInsertionsDeletions)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == kJSBFSErrorDomain)
            XCTAssert(JSBFSErrorCode(rawValue: error.code)! == .directoryNotFoundAndNotCreated)
        }
    }

    func testObservedDirectoryURLInitFileConflictExistsCreate() {
        do {
            let data = Data("".utf8)
            try data.write(to: precalculatedURL, options: .atomic)
            let _ = try JSBFSObservedDirectory(directoryURL: self.precalculatedURL,
                                               createIfNeeded: false,
                                               sortedBy: .nameAFirst,
                                               filteredBy: nil,
                                               changeKind: .modificationsAsInsertionsDeletions)
            let _ = try JSBFSObservedDirectory(directoryURL: self.precalculatedURL,
                                               createIfNeeded: true,
                                               sortedBy: .nameAFirst,
                                               filteredBy: nil,
                                               changeKind: .modificationsAsInsertionsDeletions)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == kJSBFSErrorDomain)
            XCTAssert(JSBFSErrorCode(rawValue: error.code)! == .specifiedURLIsFileExpectedDirectory)
        }
    }

}
