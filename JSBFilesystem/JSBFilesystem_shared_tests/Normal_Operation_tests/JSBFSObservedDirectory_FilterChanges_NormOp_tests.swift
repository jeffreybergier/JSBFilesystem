//
//  JSBFSObservedDirectory_FilterChanges_NormOp_tests.swift
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

class JSBFSObservedDirectory_FilterChanges_NormOp_tests: XCTestCase {

    var UUID: String {
        return Foundation.UUID().uuidString
    }

    var testPathComponent: String {
        return "FileSystemTests/" + UUID + ".directory"
    }

    var dirURL: URL!
    var observer: JSBFSObservedDirectory!
    var fm: FileManager { return FileManager.default }
    let timeout: TimeInterval = 2
    let delay: TimeInterval = 0.5

    override func setUp() {
        super.setUp()

        self.dirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
            .appendingPathComponent(testPathComponent, isDirectory: true)
        do {
            let count = 100
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
        self.observer.changesObserved = nil
        try! self.fm.removeItem(at: self.dirURL)
    }

    func testNoFilterToFilterChange() {
        do {
            let expectation = XCTestExpectation(description: "")
            self.observer = try JSBFSObservedDirectory(directoryURL: self.dirURL,
                                                       createIfNeeded: true,
                                                       sortedBy: .nameAFirst,
                                                       filteredBy: nil,
                                                       changeKind:.includingModifications)
            self.observer.changesObserved = { change in
                let change = change as! JSBFSDirectoryChangesFull
                XCTAssert(try! self.observer.contentsCount() == 0)
                XCTAssert(change.deletions.count == 100)
                XCTAssert(change.insertions.count == 0)
                XCTAssert(change.moves.count == 0)
                XCTAssert(change.updates.count == 0)
                expectation.fulfill()
            }
            self.observer.filteredBy = [
                { _ in return true },
                { _ in return false }
            ]
            self.observer.forceUpdate()
            self.wait(for: [expectation], timeout: timeout)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testFilterToNoFilterChange() {
        let filters: [@convention(block) (URL) -> Bool] =
            [
                { _ in return true },
                { _ in return false }
        ]
        do {
            let expectation = XCTestExpectation(description: "")
            self.observer = try JSBFSObservedDirectory(directoryURL: self.dirURL,
                                                       createIfNeeded: true,
                                                       sortedBy: .nameAFirst,
                                                       filteredBy: filters,
                                                       changeKind:.includingModifications)
            self.observer.changesObserved = { change in
                let change = change as! JSBFSDirectoryChangesFull
                XCTAssert(try! self.observer.contentsCount() == 100)
                XCTAssert(change.deletions.count == 0)
                XCTAssert(change.insertions.count == 100)
                XCTAssert(change.moves.count == 0)
                XCTAssert(change.updates.count == 0)
                expectation.fulfill()
            }
            self.observer.filteredBy = nil
            self.observer.forceUpdate()
            self.wait(for: [expectation], timeout: timeout)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testNoFilterToHalfEliminatedChange() {
        do {
            let expectation = XCTestExpectation(description: "")
            self.observer = try JSBFSObservedDirectory(directoryURL: self.dirURL,
                                                       createIfNeeded: true,
                                                       sortedBy: .nameAFirst,
                                                       filteredBy: nil,
                                                       changeKind:.includingModifications)
            self.observer.changesObserved = { change in
                let change = change as! JSBFSDirectoryChangesFull
                XCTAssert(try! self.observer.contentsCount() == 50)
                XCTAssert(change.deletions.count == 50)
                XCTAssert(change.insertions.count == 0)
                XCTAssert(change.moves.count == 0)
                XCTAssert(change.updates.count == 0)
                expectation.fulfill()
            }
            self.observer.filteredBy = [
                { url -> Bool in
                    let lastPath = url.lastPathComponent
                    let numberString = lastPath.trimmingCharacters(in: CharacterSet.letters)
                    let number = Int(Double(numberString)!)
                    return (number % 2 == 0) ? true : false
                }
            ]
            self.observer.forceUpdate()
            self.wait(for: [expectation], timeout: timeout)
        } catch {
            XCTFail(String(describing: error))
        }
    }
}
