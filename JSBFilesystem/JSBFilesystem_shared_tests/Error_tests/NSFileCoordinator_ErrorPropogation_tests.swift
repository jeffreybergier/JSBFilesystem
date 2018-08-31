//
//  NSFileCoordinator_ErrorPropogation_tests.swift
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/27/18.
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

class NSFileCoordinator_ErrorPropogation_tests: XCTestCase {

    let invalidLocalURL = URL(string: "file:///\(UUID().uuidString)")!
    let validRemoteURL = URL(string: "http://www.apple.com")!
    let validData = "S".data(using: .utf8)!
    let validFileWrapper = FileWrapper()

    func testNSFCWriteErrorProp() {
        do {
            try NSFileCoordinator.JSBFS_write(self.validData, to: self.invalidLocalURL, filePresenter: nil)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == NSCocoaErrorDomain)
            XCTAssert(error.code == 513)
        }
        do {
            try NSFileCoordinator.JSBFS_write(self.validFileWrapper, to: self.invalidLocalURL, filePresenter: nil)
        } catch let error as NSError {
            XCTAssert(error.domain == NSCocoaErrorDomain)
            XCTAssert(error.code == 513)
        }
    }

    func testNSFCReadErrorProp() {
        do {
            try NSFileCoordinator.JSBFS_readData(from: self.invalidLocalURL, filePresenter: nil)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == NSCocoaErrorDomain)
            XCTAssert(error.code == 260)
        }
        do {
            try NSFileCoordinator.JSBFS_readFileWrapper(from: self.invalidLocalURL, filePresenter: nil)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == NSCocoaErrorDomain)
            XCTAssert(error.code == 260)
        }
    }

    func testNSFCReadWriteTransformErrorProp() {
        do {
            try NSFileCoordinator.JSBFS_readAndWriteData(at: self.invalidLocalURL,
                                                         afterTransforming: { return $0 },
                                                         filePresenter: nil)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == NSCocoaErrorDomain)
            XCTAssert(error.code == 260)
        }
        do {
            try NSFileCoordinator.JSBFS_readAndWriteFileWrapper(at: self.invalidLocalURL,
                                                                afterTransforming: { return $0 },
                                                                filePresenter: nil)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == NSCocoaErrorDomain)
            XCTAssert(error.code == 260)
        }
    }

    func testNSFCDeleteErrorProp() {
        do {
            try NSFileCoordinator.JSBFS_delete(url: self.invalidLocalURL, filePresenter: nil)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == NSCocoaErrorDomain)
            XCTAssert(error.code == 4)
        }
        do {
            try NSFileCoordinator.JSBFS_batchDelete(urls: [self.invalidLocalURL, self.validRemoteURL], filePresenter: nil)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == NSCocoaErrorDomain)
            XCTAssert(error.code == 4)
        }
    }

    func testNSFCCreateDirectoryErrorProp() {
        do {
            try NSFileCoordinator.JSBFS_createDirectory(at: self.validRemoteURL, filePresenter: nil)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == NSCocoaErrorDomain)
            XCTAssert(error.code == 518)
        }
    }

    func testNSFCContentsOfDirectoryErrorProp() {
        do {
            try NSFileCoordinator.JSBFS_contentsOfDirectory(at: self.invalidLocalURL,
                                                            sortedBy: .nameAFirst,
                                                            filteredBy: nil,
                                                            filePresenter: nil)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == NSCocoaErrorDomain)
            XCTAssert(error.code == 260)
        }
        do {
            try NSFileCoordinator.JSBFS_comparableContentsOfDirectory(at: self.invalidLocalURL,
                                                                      sortedBy: .nameAFirst,
                                                                      filteredBy: nil,
                                                                      filePresenter: nil)
            XCTFail()
        } catch let error as NSError {
            XCTAssert(error.domain == NSCocoaErrorDomain)
            XCTAssert(error.code == 260)
        }
    }

    func testNSFCFileExistsAndIsDirectoryErrorProp() {
        // this one I can't test. The inner operation does not take an error
        // and I can't seem to get NSFileCoordinator to give an error no matter what I do to it
        do {
            let value = try NSFileCoordinator.JSBFS_fileExistsAndIsDirectory(at: self.validRemoteURL, filePresenter: nil)
            XCTAssert(value.value1 == false)
            XCTAssert(value.value2 == false)
        } catch {
            XCTFail(String(describing: error))
        }
    }

//    func testNSFCExecuteBlockErrorProp() {
//        // this one I can't test. The block does not take an error
//        // and I can't seem to get NSFileCoordinator to give an error no matter what I do to it
//        do {
//            var myVar: Int?
//            try NSFileCoordinator.JSBFS_execute({ myVar = 5 },
//                                                whileCoordinatingAccessAt: self.invalidLocalURL,
//                                                filePresenter: nil)
//            XCTAssert(myVar != nil)
//            XCTAssert(myVar! == 5)
//        } catch {
//            XCTFail(String(describing: error))
//        }
//    }

}
