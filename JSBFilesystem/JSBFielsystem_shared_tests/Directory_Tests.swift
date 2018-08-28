//
//  Directory_Tests.swift
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 24/07/2018.
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

class Directory_BasicTests: XCTestCase {

    var UUID: String {
        return Foundation.UUID().uuidString
    }

    var testPathComponent: String {
        return "FileSystemTests/" + UUID + ".directory"
    }

    func testDirectoryCreation() {
        do {
            let dir = try JSBFSDirectory(base: .cachesDirectory,
                                         appendingPathComponent: testPathComponent,
                                         createIfNeeded: true,
                                         sortedBy: JSBFSDirectorySortConverter.defaultSort,
                                         filteredBy: nil)
            var isDirectory: ObjCBool = false
            let isExisting = FileManager.default.fileExists(atPath: dir.url.path, isDirectory: &isDirectory)
            print(dir.url)
            XCTAssert(isDirectory.boolValue && isExisting)
        } catch {
            XCTAssert(false, String(describing: error))
        }
    }

    func testDirectoryNonCreation() {
        do {
            _ = try JSBFSDirectory(base: .cachesDirectory,
                                   appendingPathComponent: testPathComponent,
                                   createIfNeeded: false,
                                   sortedBy: JSBFSDirectorySortConverter.defaultSort,
                                   filteredBy: nil)
            XCTFail()
        } catch {
            XCTAssert(true)
        }
    }

    func testDirectoryWithFileURL() {
        let fm = FileManager.default
        let sp = FileManager.SearchPathDirectory.cachesDirectory
        let pc = testPathComponent
        do {
            let url = fm.urls(for: sp, in: .userDomainMask).first!.appendingPathComponent(pc)
            let data = Data("This should cause an error".utf8)
            try data.write(to: url)
        } catch {
            XCTAssert(false, String(describing: error))
        }
        do {
            _ = try JSBFSDirectory(base: .cachesDirectory,
                                   appendingPathComponent: testPathComponent,
                                   createIfNeeded: false,
                                   sortedBy: JSBFSDirectorySortConverter.defaultSort,
                                   filteredBy: nil)
            XCTFail()
        } catch {
            XCTAssert(true)
        }
    }

    func testIndexOfItemAtURLNotFound() {
        do {
            let dir = try JSBFSDirectory(base: .cachesDirectory,
                                         appendingPathComponent: testPathComponent,
                                         createIfNeeded: true,
                                         sortedBy: JSBFSDirectorySortConverter.defaultSort,
                                         filteredBy: nil)
            let fakeURL = URL(string:"file:///myfakeurl.txt")!
            let _ = try dir.indexOfItem(with: fakeURL)
            XCTFail("An error should have been thrown")
        } catch (let error as NSError) {
            XCTAssert(error.domain == kJSBFSErrorDomain)
            XCTAssert(JSBFSErrorCode(rawValue: error.code)! == .itemNotFound)
        } catch {
            XCTFail(String(describing: error))
        }
    }
}

class Directory_FilterTests: XCTestCase {

    var UUID: String {
        return Foundation.UUID().uuidString
    }

    var testPathComponent: String {
        return "FileSystemTests/" + UUID + ".directory"
    }

    var dirURL: URL!
    var directory: JSBFSDirectory!
    var fm: FileManager { return FileManager.default }
    let timeout: TimeInterval = 2
    let delay: TimeInterval = 0.5
    let originalCount = 100

    override func setUp() {
        super.setUp()

        self.dirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
            .appendingPathComponent(testPathComponent, isDirectory: true)
        do {
            let count = self.originalCount
            let fm = FileManager.default
            try fm.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
            for i in 0 ..< count {
                let file = "\(i).file"
                let url = dirURL.appendingPathComponent(file)
                let data = Data(file.utf8)
                try data.write(to: url)
            }
        } catch {
            XCTFail(String(describing: error))
        }
    }
    override func tearDown() {
        super.tearDown()
        try! self.fm.removeItem(at: self.dirURL)
    }

    func testFilterTwoPass() {
        do {
            let filter1: (URL) -> Bool = { _ in return true }
            let filter2: (URL) -> Bool = { _ in return true }
            self.directory = try JSBFSDirectory(directoryURL: self.dirURL,
                                                createIfNeeded: true,
                                                sortedBy: JSBFSDirectorySortConverter.defaultSort,
                                                filteredBy: [filter1, filter2])
            let contentsCount = try self.directory.contentsCount()
            XCTAssert(contentsCount == self.originalCount)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testFilterOneFail() {
        do {
            let filter1: (URL) -> Bool = { _ in return true }
            let filter2: (URL) -> Bool = { _ in return false }
            self.directory = try JSBFSDirectory(directoryURL: self.dirURL,
                                                createIfNeeded: true,
                                                sortedBy: JSBFSDirectorySortConverter.defaultSort,
                                                filteredBy: [filter1, filter2])
            let contentsCount = try self.directory.contentsCount()
            XCTAssert(contentsCount == 0)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testFilterBothFail() {
        do {
            let filter1: (URL) -> Bool = { _ in return false }
            let filter2: (URL) -> Bool = { _ in return false }
            self.directory = try JSBFSDirectory(directoryURL: self.dirURL,
                                                createIfNeeded: true,
                                                sortedBy: JSBFSDirectorySortConverter.defaultSort,
                                                filteredBy: [filter1, filter2])
            let contentsCount = try self.directory.contentsCount()
            XCTAssert(contentsCount == 0)
        } catch {
            XCTFail(String(describing: error))
        }
    }
}
