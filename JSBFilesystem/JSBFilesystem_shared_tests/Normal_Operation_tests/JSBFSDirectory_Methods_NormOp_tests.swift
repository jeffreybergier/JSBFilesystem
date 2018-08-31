//
//  JSBFSDirectory_Methods_NormOp_tests.swift
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

class JSBFSDirectory_Methods_NormOp_tests: XCTestCase {

    class func fileName(for index: Int) -> String {
        return String(format:"%02.0f", Float(index)) + ".testfile"
    }

    var directory: JSBFSDirectory!
    let fileCount: Int = 20

    override func setUp() {
        self.directory = try! JSBFSDirectory(base: .cachesDirectory,
                                             appendingPathComponent: UUID().uuidString,
                                             createIfNeeded: true,
                                             sortedBy: .nameAFirst,
                                             filteredBy: nil)
        // create files
        self.makeFakeFiles()
    }

    override func tearDown() {
        try! FileManager.default.removeItem(at: self.directory.url)
    }

    func makeFakeFiles() {
        for i in 0..<self.fileCount {
            let fileName = type(of: self).fileName(for: i)
            let data = Data(fileName.utf8)
            let url = self.directory.url.appendingPathComponent(fileName)
            try! data.write(to: url)
        }
    }

    func testDirectoryContentsCount() {
        do {
            let count = try self.directory.contentsCount()
            XCTAssert(count == self.fileCount)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }

    func testDirectoryURLAtIndex() {
        do {
            let firstURL = try self.directory.url(at: 0)
            let lastURL = try self.directory.url(at: self.fileCount - 1)
            XCTAssert(firstURL.lastPathComponent == type(of: self).fileName(for: 0))
            XCTAssert(lastURL.lastPathComponent == type(of: self).fileName(for: self.fileCount - 1))
            let firstData = try Data(contentsOf: firstURL)
            let lastData = try Data(contentsOf: lastURL)
            XCTAssert(firstData == Data(type(of: self).fileName(for: 0).utf8))
            XCTAssert(lastData == Data(type(of: self).fileName(for: self.fileCount - 1).utf8))
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }

    func testDirectoryContentsDeleteAll() {
        do {
            try self.directory.deleteContents()
            let count = try self.directory.contentsCount()
            XCTAssert(count == 0)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }

    func testDirectoryContentsDeleteFiltered() {
        do {
            do {
                let preFilterPreDeleteCount = try self.directory.contentsCount()
                XCTAssert(preFilterPreDeleteCount == self.fileCount)
            }
            self.directory.filteredBy = [{ _ in return false }]
            do {
                let postFilterPreDeleteCount = try self.directory.contentsCount()
                XCTAssert(postFilterPreDeleteCount == 0)
            }
            try self.directory.deleteContents()
            do {
                let postFilterPostDeleteCount = try self.directory.contentsCount()
                XCTAssert(postFilterPostDeleteCount == 0)
            }
            self.directory.filteredBy = nil
            do {
                let preFilterPostDeleteCount = try self.directory.contentsCount()
                XCTAssert(preFilterPostDeleteCount == self.fileCount)
            }
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }

    func testDirectoryIndexOfURLWithValidURL() {
        do {
            let testIndex = self.fileCount / 2
            let testURL = self.directory.url.appendingPathComponent(type(of: self).fileName(for: testIndex))
            let discoveredIndex = try self.directory.indexOfItem(with: testURL)
            let discoveredURL = try self.directory.url(at: discoveredIndex)
            XCTAssert(testIndex == discoveredIndex)
            XCTAssert(discoveredURL.path == testURL.path)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }

    func testDirectoryIndexOfURLWithInvalidURL() {
        do {
            let testURL = URL(string: "https://www.apple.com")!
            let _ = try self.directory.indexOfItem(with: testURL)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == kJSBFSErrorDomain)
            XCTAssert(JSBFSErrorCode(rawValue: error.code)! == .itemNotFound)
        }
    }

}
