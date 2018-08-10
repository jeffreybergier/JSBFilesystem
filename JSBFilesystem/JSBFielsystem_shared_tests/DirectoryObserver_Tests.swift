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

class DirectoryObserver_BasicTests: XCTestCase {

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

    func testAddFileDiff() {
        let expectation = XCTestExpectation(description: "Change closure will be called, diff will show 1 added item")
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
        let expectation = XCTestExpectation(description: "Change closure will be called, diff will show 1 added item")
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
        let expectation = XCTestExpectation(description: "Change closure will be called, diff will show 1 added item")
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
        let expectation = XCTestExpectation(description: "Change closure will be called, diff will show 1 added item")
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
        let expectation = XCTestExpectation(description: "Change closure should get JSBFSDirectoryChangesFull object")
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
        let expectation = XCTestExpectation(description: "Change closure should get JSBFSDirectoryChanges object")
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

    func testIndexOfItemAtURL() {
        do {
            self.observer = try! JSBFSObservedDirectory(directoryURL: self.dirURL,
                                                        createIfNeeded: true,
                                                        sortedBy: .nameAFirst,
                                                        filteredBy: nil,
                                                        changeKind:.modificationsAsInsertionsDeletions)
            self.observer.changesObserved = { _ in }
            let index0URL = try self.observer.url(at: 0)
            let index1URL = try self.observer.url(at: 1)
            let index0 = try self.observer.indexOfItem(with: index0URL)
            let index1 = try self.observer.indexOfItem(with: index1URL)
            XCTAssert(index0 == 0)
            XCTAssert(index1 == 1)
            let data0 = try self.observer.data(at: index0)
            let data1 = try self.observer.data(at: index1)
            let string0 = String(data: data0, encoding: .utf8)!
            let string1 = String(data: data1, encoding: .utf8)!
            XCTAssert(string0 == "0.file")
            XCTAssert(string1 == "1.file")
        } catch {
            XCTFail(String(describing: error))
        }
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
            XCTFail("An error should have been thrown")
        } catch (let error as NSError) {
            XCTAssert(error.domain == "JSBFilesystem" && error.code == 1, String(describing: error))
        } catch {
            XCTFail(String(describing: error))
        }
    }
}

class DirectoryObserver_FilterTests: XCTestCase {

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
            let expectation = XCTestExpectation(description: "Change should show all elements being deleted")
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
        let filters: [@convention(block) (URL) -> Bool] = [
            { _ in return true },
            { _ in return false }
        ]
        do {
            let expectation = XCTestExpectation(description: "Change should show all elements being deleted")
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
            let expectation = XCTestExpectation(description: "Change should show all elements being deleted")
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
