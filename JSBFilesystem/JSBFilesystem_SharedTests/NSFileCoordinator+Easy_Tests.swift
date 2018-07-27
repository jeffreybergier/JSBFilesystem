//
//  NSFileCoordinator+Easy_Tests.swift
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 23/07/2018.
//

import XCTest
@testable import JSBFilesystem

class NSFileCoordinator_Easy_BasicTests: XCTestCase {

    var UUID: String {
        return Foundation.UUID().uuidString
    }

    func testWrite() {
        let string = UUID
        let data = Data(string.utf8)
        let url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(UUID)
        do {
            try NSFileCoordinator.JSBFS_write(data, to: url)
            let dataFromDisk = try Data(contentsOf: url)
            let stringFromDisk = String(data: dataFromDisk, encoding: .utf8)
            XCTAssertNotNil(stringFromDisk)
            XCTAssert(stringFromDisk == string)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testRead() {
        let string = UUID
        let data = Data(string.utf8)
        let url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(UUID)
        do {
            try data.write(to: url)
            let dataFromDisk = try NSFileCoordinator.JSBFS_readData(from: url)
            let stringFromDisk = String(data: dataFromDisk, encoding: .utf8)
            XCTAssertNotNil(stringFromDisk)
            XCTAssert(stringFromDisk == string)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testCreateDirectory() {
        let url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
        do {
            try NSFileCoordinator.JSB_createDirectory(at: url)
            var isDirectory: ObjCBool = false
            let isExisting = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
            XCTAssert(isExisting && isDirectory.boolValue)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testFileExistsAndIsDirectory_Directory() {
        let url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            let (isExisting, isDirectory) = try NSFileCoordinator.JSB_fileExistsAndIsDirectory(at: url)
            XCTAssert(isExisting && isDirectory)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testFileExistsAndIsDirectory_File() {
        let dirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
        let url = dirURL.appendingPathComponent(UUID, isDirectory: false)
        let data = Data(UUID.utf8)
        do {
            try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
            try data.write(to: url)
            let (isExisting, isDirectory) = try NSFileCoordinator.JSB_fileExistsAndIsDirectory(at: url)
            XCTAssert(isExisting == true && isDirectory == false)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testDelete() {
        let dirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
        let url = dirURL.appendingPathComponent(UUID, isDirectory: false)
        let data = Data(UUID.utf8)
        do {
            try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
            try data.write(to: url)
            try NSFileCoordinator.JSB_delete(at: url)
            let isExisting = FileManager.default.fileExists(atPath: url.path)
            XCTAssertFalse(isExisting)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testMove() {
        let dir1URL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(UUID, isDirectory: true)
        let dir2URL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(UUID, isDirectory: true)
        let beforeURL = dir1URL.appendingPathComponent(UUID, isDirectory: false)
        let afterURL = dir2URL.appendingPathComponent(UUID, isDirectory: false)
        let data = Data(UUID.utf8)
        do {
            try FileManager.default.createDirectory(at: dir1URL, withIntermediateDirectories: true, attributes: nil)
            try data.write(to: beforeURL)
            try NSFileCoordinator.JSB_move(from: beforeURL, to: afterURL)
            let beforeExists = FileManager.default.fileExists(atPath: beforeURL.path)
            let afterExists = FileManager.default.fileExists(atPath: afterURL.path)
            XCTAssert(beforeExists == false && afterExists == true)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testFileCountInDirectory() {
        let dirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
        do {
            let testCount = 100
            try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
            for i in 0 ..< testCount {
                let data = Data("This is file \(i)".utf8)
                let url = dirURL.appendingPathComponent("\(i).txt", isDirectory: false)
                try data.write(to: url)
            }
            let count = try NSFileCoordinator.JSB_fileCountInDirectory(at: dirURL)
            XCTAssert(count == testCount)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testAscendingAlphabeticalSort() {
        let dirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
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
            let urls = try NSFileCoordinator.JSB_directoryContentsURLsAndModificationDates(ofDirectoryURL: dirURL,
                                                                                           sortedBy: .localizedNameKey,
                                                                                           ascending: true)
            XCTAssert(urls.count == count)
            XCTAssert(urls.first!.fileURL.lastPathComponent == "0.file")
            XCTAssert(urls.last!.fileURL.lastPathComponent == "99.file")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testDescendingAlphabeticalSort() {
        let dirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
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
            let urls = try NSFileCoordinator.JSB_directoryContentsURLsAndModificationDates(ofDirectoryURL: dirURL,
                                                                                           sortedBy: .localizedNameKey,
                                                                                           ascending: false)
            XCTAssert(urls.count == count)
            XCTAssert(urls.last!.fileURL.lastPathComponent == "0.file")
            XCTAssert(urls.first!.fileURL.lastPathComponent == "99.file")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testAscendingCreationDateSort() {
        let dirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
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
            let urls = try NSFileCoordinator.JSB_directoryContentsURLsAndModificationDates(ofDirectoryURL: dirURL,
                                                                                           sortedBy: .creationDateKey,
                                                                                           ascending: true)
            XCTAssert(urls.count == count)
            XCTAssert(urls.first!.fileURL.lastPathComponent == "0.file")
            XCTAssert(urls.last!.fileURL.lastPathComponent == "99.file")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testDescendingCreationDateSort() {
        let dirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
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
            let urls = try NSFileCoordinator.JSB_directoryContentsURLsAndModificationDates(ofDirectoryURL: dirURL,
                                                                                           sortedBy: .creationDateKey,
                                                                                           ascending: false)
            XCTAssert(urls.count == count)
            XCTAssert(urls.last!.fileURL.lastPathComponent == "0.file")
            XCTAssert(urls.first!.fileURL.lastPathComponent == "99.file")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testAscendingModificationDateSort() {
        let dirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
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
            let modURL = dirURL.appendingPathComponent("10.file")
            let data = Data("MODIFIED".utf8)
            try data.write(to: modURL)
            let urls = try NSFileCoordinator.JSB_directoryContentsURLsAndModificationDates(ofDirectoryURL: dirURL,
                                                                                           sortedBy: .contentModificationDateKey,
                                                                                           ascending: true)
            XCTAssert(urls.count == count)
            XCTAssert(urls.last!.fileURL.lastPathComponent == "10.file")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testDescendingModificationDateSort() {
        let dirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
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
            let modURL = dirURL.appendingPathComponent("10.file")
            let data = Data("MODIFIED".utf8)
            try data.write(to: modURL)
            let urls = try NSFileCoordinator.JSB_directoryContentsURLsAndModificationDates(ofDirectoryURL: dirURL,
                                                                                           sortedBy: .contentModificationDateKey,
                                                                                           ascending: false)
            XCTAssert(urls.count == count)
            XCTAssert(urls.first!.fileURL.lastPathComponent == "10.file")
        } catch {
            XCTFail(String(describing: error))
        }
    }

}

