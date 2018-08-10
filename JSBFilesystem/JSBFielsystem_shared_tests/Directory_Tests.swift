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

    func testIndexOfItemAtURL() {
        let _string0 = "File1"
        let _string1 = "File2"
        let _data0 = Data(_string0.utf8)
        let _data1 = Data(_string1.utf8)
        do {
            let dir = try JSBFSDirectory(base: .cachesDirectory,
                                         appendingPathComponent: testPathComponent,
                                         createIfNeeded: true,
                                         sortedBy: JSBFSDirectorySortConverter.defaultSort,
                                         filteredBy: nil)
            try dir.createFileNamed("data1.txt", with: _data0)
            try dir.createFileNamed("data2.txt", with: _data1)
            let index0URL = try dir.url(at: 0)
            let index1URL = try dir.url(at: 1)
            let index0 = try dir.indexOfItem(with: index0URL)
            let index1 = try dir.indexOfItem(with: index1URL)
            XCTAssert(index0 == 0)
            XCTAssert(index1 == 1)
            let data0 = try dir.data(at: index0)
            let data1 = try dir.data(at: index1)
            let string0 = String(data: data0, encoding: .utf8)!
            let string1 = String(data: data1, encoding: .utf8)!
            XCTAssert(string0 == _string0)
            XCTAssert(string1 == _string1)
        } catch {
            XCTFail(String(describing: error))
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
            XCTAssert(error.domain == "JSBFilesystem" && error.code == 1, String(describing: error))
        } catch {
            XCTFail(String(describing: error))
        }
    }
}
