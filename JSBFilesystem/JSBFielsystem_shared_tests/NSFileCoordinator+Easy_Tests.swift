//
//  NSFileCoordinator+Easy_Tests.swift
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 23/07/2018.
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
            try NSFileCoordinator.JSBFS_createDirectory(at: url)
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
            let value = try NSFileCoordinator.JSBFS_fileExistsAndIsDirectory(at: url)
            let (isExisting, isDirectory) = (value.value1, value.value2)
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
            let value = try NSFileCoordinator.JSBFS_fileExistsAndIsDirectory(at: url)
            let (isExisting, isDirectory) = (value.value1, value.value2)
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
            try NSFileCoordinator.JSBFS_recursivelyDeleteDirectoryOrFile(at: url)
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
            try NSFileCoordinator.JSBFS_move(sourceFile: beforeURL, toDestinationFile: afterURL)
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
            let count = try NSFileCoordinator.JSBFS_fileCount(inDirectoryURL: dirURL)
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
            let urls = try NSFileCoordinator.JSBFS_urlComparisonsForFiles(inDirectory: dirURL,
                                                                          sortedBy: .nameAFirst)
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
            let urls = try NSFileCoordinator.JSBFS_urlComparisonsForFiles(inDirectory: dirURL,
                                                                          sortedBy: .nameZFirst)
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
            let urls = try NSFileCoordinator.JSBFS_urlComparisonsForFiles(inDirectory: dirURL,
                                                                          sortedBy: .creationOldestFirst)
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
            let urls = try NSFileCoordinator.JSBFS_urlComparisonsForFiles(inDirectory: dirURL,
                                                                          sortedBy: .creationNewestFirst)
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
            let urls = try NSFileCoordinator.JSBFS_urlComparisonsForFiles(inDirectory: dirURL,
                                                                          sortedBy: .modificationOldestFirst)
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
            let urls = try NSFileCoordinator.JSBFS_urlComparisonsForFiles(inDirectory: dirURL,
                                                                          sortedBy: .modificationNewestFirst)
            XCTAssert(urls.count == count)
            XCTAssert(urls.first!.fileURL.lastPathComponent == "10.file")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testFileComparisonsWhenNoDirectoryPresent() {
        let dirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
        do {
            _ = try NSFileCoordinator.JSBFS_urlComparisonsForFiles(inDirectory: dirURL,
                                                                            sortedBy: .modificationNewestFirst)
            XCTFail("An error should have been thrown")
        } catch {
            XCTAssert(true, String(describing: error))
        }
    }

    func testFileComparisonsNotNilWhenDirectoryEmpty() {
        let dirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
        do {
            try NSFileCoordinator.JSBFS_createDirectory(at: dirURL)
            let urls = try NSFileCoordinator.JSBFS_urlComparisonsForFiles(inDirectory: dirURL,
                                                                   sortedBy: .modificationNewestFirst)
            XCTAssert(urls.isEmpty)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    /// Refer to Documentation on how to read and write and verify file wrappers
    /// https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileWrappers/FileWrappers.html#//apple_ref/doc/uid/TP40010672-CH13-DontLinkElementID_5
    func testFileWrapperRead() {
        let dirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
        do {
            let rawString = "this is a test"
            try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
            let innerData = Data(rawString.utf8)
            try innerData.write(to: dirURL.appendingPathComponent("innerFile.txt"))
            let parentWrapper = try NSFileCoordinator.JSBFS_readFileWrapper(from: dirURL)
            XCTAssert(parentWrapper.isDirectory)
            XCTAssert(parentWrapper.fileWrappers!.count == 1)
            let fileWrapper = parentWrapper.fileWrappers?["innerFile.txt"]
            let fileData = fileWrapper?.regularFileContents
            let fileString = String(data: fileData!, encoding: .utf8)!
            XCTAssert(fileString == rawString)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testFileWrapperWrite() {
        let sourceURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
        let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
            .appendingPathComponent(UUID, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: sourceURL, withIntermediateDirectories: true, attributes: nil)
            let childFileText = "this is a test"
            let childFileName = "innerFile.txt"
            let childFileData = Data(childFileText.utf8)
            try childFileData.write(to: sourceURL.appendingPathComponent(childFileName))
            let parentFileWrapper = try FileWrapper(url: sourceURL, options: .immediate)
            XCTAssert(parentFileWrapper.isDirectory)
            XCTAssert(parentFileWrapper.fileWrappers!.count == 1)
            try FileManager.default.createDirectory(at: destinationURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            try NSFileCoordinator.JSBFS_write(parentFileWrapper, to: destinationURL)
            let value = try NSFileCoordinator.JSBFS_fileExistsAndIsDirectory(at: destinationURL)
            XCTAssert(value.value1 && value.value2)
            let childFileDestinationData = try Data(contentsOf: destinationURL.appendingPathComponent(childFileName))
            let childFileDestinationString = String(data: childFileDestinationData, encoding: .utf8)!
            XCTAssert(childFileDestinationString == childFileText)
        } catch {
            XCTFail(String(describing: error))
        }
    }
}
