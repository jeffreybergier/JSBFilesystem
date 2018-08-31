//
//  NSFileCoordinator_ReadMethod_NormOp_tests.swift
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

class NSFileCoordinator_ReadDataMethod_NormOp_tests: XCTestCase {

    var directory: URL!
    let fileName = UUID().uuidString + ".testfile"
    let ogData = Data(UUID().uuidString.utf8)

    override func setUp() {
        let fm = FileManager.default
        self.directory = fm.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!.appendingPathComponent(UUID().uuidString)
        try! fm.createDirectory(at: self.directory,
                                withIntermediateDirectories: true,
                                attributes: nil)
        let fileURL = self.directory.appendingPathComponent(fileName)
        try! self.ogData.write(to: fileURL)
    }

    override func tearDown() {
        try! FileManager.default.removeItem(at: self.directory)
    }

    func testNSFCReadData() {
        do {
            let fileURL = self.directory.appendingPathComponent(fileName)
            let testData = try NSFileCoordinator.JSBFS_readData(from: fileURL, filePresenter: nil)
            XCTAssertNotNil(testData)
            XCTAssert(self.ogData == testData)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }
}

class NSFileCoordinator_ReadFileWrapperMethod_NormOp_tests: XCTestCase {

    var directory: URL!
    let fileName = UUID().uuidString + ".testfile"
    let ogData = Data(UUID().uuidString.utf8)
    lazy var ogFileWrapper: FileWrapper = FileWrapper(regularFileWithContents: self.ogData)

    override func setUp() {
        let fm = FileManager.default
        self.directory = fm.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!.appendingPathComponent(UUID().uuidString)
        try! fm.createDirectory(at: self.directory,
                                withIntermediateDirectories: true,
                                attributes: nil)
        let fileURL = self.directory.appendingPathComponent(fileName)
        try! self.ogFileWrapper.write(to: fileURL, options: .atomic, originalContentsURL: nil)
    }

    override func tearDown() {
        try! FileManager.default.removeItem(at: self.directory)
    }

    func testNSFCReadData() {
        do {
            let fileURL = self.directory.appendingPathComponent(fileName)
            let testWrapper = try NSFileCoordinator.JSBFS_readFileWrapper(from: fileURL, filePresenter: nil)
            XCTAssertNotNil(testWrapper.regularFileContents)
            XCTAssert(self.ogData == testWrapper.regularFileContents!)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }
}
