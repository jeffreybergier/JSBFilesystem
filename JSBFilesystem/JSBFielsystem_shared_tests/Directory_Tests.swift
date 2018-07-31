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
            let dir = try JSBFSDirectory(base: .cachesDirectory, appendingPathComponent: testPathComponent, createIfNeeded: true, sortedBy: JSBFSDirectorySortConverter.defaultSort())
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
            _ = try JSBFSDirectory(base: .cachesDirectory, appendingPathComponent: testPathComponent, createIfNeeded: false, sortedBy: JSBFSDirectorySortConverter.defaultSort())
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
            _ = try JSBFSDirectory(base: .cachesDirectory, appendingPathComponent: testPathComponent, createIfNeeded: false, sortedBy: JSBFSDirectorySortConverter.defaultSort())
            XCTFail()
        } catch {
            XCTAssert(true)
        }
    }
}
