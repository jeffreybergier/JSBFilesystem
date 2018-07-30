//
//  DirectoryObserver_Tests.swift
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 25/07/2018.
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
    var observer: JSBFSDirectoryObserver!
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
        let sort = Directory.Sort.default
        self.observer = JSBFSDirectoryObserver_Testable(directoryURL: self.dirURL,
                                                        sortedByResourceKey: sort.by.resourceValue,
                                                        orderedAscending: sort.ascending)
        self.observer.changesObserved = { changes in
            let changes = changes as! JSBFSDirectoryChanges_Testable
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
        let sort = Directory.Sort.default
        self.observer = JSBFSDirectoryObserver_Testable(directoryURL: self.dirURL,
                                                        sortedByResourceKey: sort.by.resourceValue,
                                                        orderedAscending: sort.ascending)
        self.observer.changesObserved = { changes in
            let changes = changes as! JSBFSDirectoryChanges_Testable
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
        let sort = Directory.Sort.default
        self.observer = JSBFSDirectoryObserver_Testable(directoryURL: self.dirURL,
                                                        sortedByResourceKey: sort.by.resourceValue,
                                                        orderedAscending: sort.ascending)
        self.observer.changesObserved = { changes in
            let changes = changes as! JSBFSDirectoryChanges_Testable
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
        let sort = Directory.Sort(by: .modificationDate, ascending: false)
        self.observer = JSBFSDirectoryObserver_Testable(directoryURL: self.dirURL,
                                                        sortedByResourceKey: sort.by.resourceValue,
                                                        orderedAscending: sort.ascending)
        self.observer.changesObserved = { changes in
            let changes = changes as! JSBFSDirectoryChanges_Testable
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
}
