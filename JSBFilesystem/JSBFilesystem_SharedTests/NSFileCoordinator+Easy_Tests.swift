//
//  NSFileCoordinator+Easy_Tests.swift
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 23/07/2018.
//

import XCTest
@testable import Filesystem

class NSFileCoordinator_Easy_BasicTests: XCTestCase {

    var UUID: String {
        return Foundation.UUID().uuidString
    }

    func testWrite() {
        let string = UUID
        let data = Data(string.utf8)
        let url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(UUID)
        do {
            try NSFileCoordinator.JSB_write(data: data, to: url)
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
            let dataFromDisk = try NSFileCoordinator.JSB_read(from: url)
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
            XCTAssert(isExisting && isDirectory == false)
        } catch {
            XCTFail(String(describing: error))
        }
    }
}

