//
//  DirectoryObserver_Tests.swift
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 25/07/2018.
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
@testable import JSBFilesystem

class JSBFSObservedDirectory_Changes_NormOp_tests: XCTestCase {

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
    let delay: TimeInterval = 0.3

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
        self.observer = nil
        try! self.fm.removeItem(at: self.dirURL)
    }

    func testAddFileDiff() {
        let expectation = XCTestExpectation(description: "")
        let sort = JSBFSDirectorySortConverter.defaultSort
        self.observer = try! JSBFSObservedDirectory(directoryURL: self.dirURL,
                                                    createIfNeeded: true,
                                                    sortedBy: sort,
                                                    filteredBy: nil,
                                                    changeKind:.includingModifications)
        self.observer.changesObserved = { changes in
            let changes = changes as! JSBFSDirectoryChangesFull
            XCTAssert(changes.insertions.count == 2)
            XCTAssert(changes.insertions.first! == 1)
            XCTAssert(changes.insertions.last! == 11)
            XCTAssert(changes.deletions.isEmpty)
            XCTAssert(changes.updates.isEmpty)
            XCTAssert(changes.moves.isEmpty)
            expectation.fulfill()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let newData = Data("This was added".utf8)
            try! newData.write(to: self.dirURL.appendingPathComponent("075.file"))
            try! newData.write(to: self.dirURL.appendingPathComponent("175.file"))
        }
        self.wait(for: [expectation], timeout: timeout)
    }

    func testDeleteFileDiff() {
        let expectation = XCTestExpectation(description: "")
        let sort = JSBFSDirectorySortConverter.defaultSort
        self.observer = try! JSBFSObservedDirectory(directoryURL: self.dirURL,
                                                    createIfNeeded: true,
                                                    sortedBy: sort,
                                                    filteredBy: nil,
                                                    changeKind:.includingModifications)
        self.observer.changesObserved = { changes in
            let changes = changes as! JSBFSDirectoryChangesFull
            XCTAssert(changes.deletions.count == 2)
            XCTAssert(changes.deletions.first! == 18)
            XCTAssert(changes.deletions.last! == 73)
            XCTAssert(changes.insertions.isEmpty)
            XCTAssert(changes.updates.isEmpty)
            XCTAssert(changes.moves.isEmpty)
            expectation.fulfill()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            try! self.fm.removeItem(at: self.dirURL.appendingPathComponent("75.file"))
            try! self.fm.removeItem(at: self.dirURL.appendingPathComponent("25.file"))
        }
        self.wait(for: [expectation], timeout: timeout)
    }

    func testChangeFileDiff() {
        let expectation = XCTestExpectation(description: "")
        let sort = JSBFSDirectorySortConverter.defaultSort
        self.observer = try! JSBFSObservedDirectory(directoryURL: self.dirURL,
                                                    createIfNeeded: true,
                                                    sortedBy: sort,
                                                    filteredBy: nil,
                                                    changeKind:.includingModifications)
        self.observer.changesObserved = { changes in
            let changes = changes as! JSBFSDirectoryChangesFull
            XCTAssert(changes.updates.count == 2)
            XCTAssert(changes.updates.first! == 18)
            XCTAssert(changes.updates.last! == 73)
            XCTAssert(changes.deletions.isEmpty)
            XCTAssert(changes.insertions.isEmpty)
            XCTAssert(changes.moves.isEmpty)
            expectation.fulfill()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let newData = Data("This was added".utf8)
            try! newData.write(to: self.dirURL.appendingPathComponent("75.file"))
            try! newData.write(to: self.dirURL.appendingPathComponent("25.file"))
        }
        self.wait(for: [expectation], timeout: timeout)
    }

    func testMoveFileDiff() {
        let expectation = XCTestExpectation(description: "")
        let sort = JSBFSDirectorySort.modificationNewestFirst
        self.observer = try! JSBFSObservedDirectory(directoryURL: self.dirURL,
                                                    createIfNeeded: true,
                                                    sortedBy: sort,
                                                    filteredBy: nil,
                                                    changeKind:.includingModifications)
        self.observer.changesObserved = { changes in
            let changes = changes as! JSBFSDirectoryChangesFull
            XCTAssert(changes.updates.count == 1)
            XCTAssert(changes.moves.count == 5)
            XCTAssert(changes.moves.contains(where: { $0.from == 4 && $0.to == 0 }))
            XCTAssert(changes.deletions.isEmpty)
            XCTAssert(changes.insertions.isEmpty)
            expectation.fulfill()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let newData = Data("This was added".utf8)
            try! newData.write(to: self.dirURL.appendingPathComponent("95.file"))
        }
        self.wait(for: [expectation], timeout: timeout)
    }

    func testChangesIncludingModifications() {
        let expectation = XCTestExpectation(description: "")
        let sort = JSBFSDirectorySort.modificationNewestFirst
        self.observer = try! JSBFSObservedDirectory(directoryURL: self.dirURL,
                                                    createIfNeeded: true,
                                                    sortedBy: sort,
                                                    filteredBy: nil,
                                                    changeKind:.includingModifications)
        self.observer.changesObserved = { changes in
            XCTAssert(changes.isMember(of: JSBFSDirectoryChangesFull.self))
            XCTAssertFalse(changes.isMember(of: JSBFSDirectoryChanges.self))
            expectation.fulfill()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let newData = Data("This was added".utf8)
            try! newData.write(to: self.dirURL.appendingPathComponent("95.file"))
        }
        self.wait(for: [expectation], timeout: timeout)
    }

    func testChangesWithModificationsAsInsertionsDeletions() {
        let expectation = XCTestExpectation(description: "")
        let sort = JSBFSDirectorySort.modificationNewestFirst
        self.observer = try! JSBFSObservedDirectory(directoryURL: self.dirURL,
                                                    createIfNeeded: true,
                                                    sortedBy: sort,
                                                    filteredBy: nil,
                                                    changeKind:.modificationsAsInsertionsDeletions)
        self.observer.changesObserved = { changes in
            XCTAssertFalse(changes.isMember(of: JSBFSDirectoryChangesFull.self))
            XCTAssert(changes.isMember(of: JSBFSDirectoryChanges.self))
            expectation.fulfill()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let newData = Data("This was added".utf8)
            try! newData.write(to: self.dirURL.appendingPathComponent("95.file"))
        }
        self.wait(for: [expectation], timeout: timeout)
    }

    func testIndexOfItemAtURLNotFound() {
        do {
            self.observer = try! JSBFSObservedDirectory(directoryURL: self.dirURL,
                                                        createIfNeeded: true,
                                                        sortedBy: .nameAFirst,
                                                        filteredBy: nil,
                                                        changeKind:.modificationsAsInsertionsDeletions)
            self.observer.changesObserved = { _ in }
            let fakeURL = URL(string:"file:///myfakeurl.txt")!
            let _ = try self.observer.indexOfItem(with: fakeURL)
            XCTFail()
        } catch (let error as NSError) {
            XCTAssert(error.domain == kJSBFSErrorDomain)
            XCTAssert(JSBFSErrorCode(rawValue: error.code)! == .itemNotFound)
        } catch {
            XCTFail(String(describing: error))
        }
    }
}
