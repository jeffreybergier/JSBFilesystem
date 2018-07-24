//
//  Directory_Tests.swift
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 24/07/2018.
//

import XCTest
import Filesystem

class Directory_BasicTests: XCTestCase {

    var UUID: String {
        return Foundation.UUID().uuidString
    }

    var testPathComponent: String {
        return "FileSystemTests/" + UUID + ".directory"
    }

    func testDirectoryCreation() {
        do {
            let dir = try Directory(base: .cachesDirectory, appendingPathComponent: testPathComponent, createIfNeeded: true)
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
            _ = try Directory(base: .cachesDirectory, appendingPathComponent: testPathComponent, createIfNeeded: false)
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
            _ = try Directory(base: sp, appendingPathComponent: pc, createIfNeeded: false)
            XCTFail()
        } catch {
            XCTAssert(true)
        }
    }
}
