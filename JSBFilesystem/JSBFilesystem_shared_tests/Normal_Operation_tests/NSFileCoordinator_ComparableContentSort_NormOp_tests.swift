//
//  NSFileCoordinator_ContentSort_NormOp_tests.swift
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/29/18.
//

import XCTest
import JSBFilesystem

class NSFileCoordinator_ComparableContentSort_NormOp_tests: XCTestCase {

    class func fileName(for index: Int) -> String {
        return String(format:"%02.0f", Float(index)) + ".testfile"
    }

    var directory: URL!
    let fileCount = 20
    var modifiedIndex: Int!
    var creationResetIndex: Int!

    override func setUp() {
        let fm = FileManager.default
        self.directory = fm.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!.appendingPathComponent(UUID().uuidString)
        try! fm.createDirectory(at: self.directory,
                                withIntermediateDirectories: true,
                                attributes: nil)
        // create files
        for i in 0..<self.fileCount {
            let fileName = type(of: self).fileName(for: i)
            let data = Data(fileName.utf8)
            let url = self.directory.appendingPathComponent(fileName)
            try! data.write(to: url)
        }

        // reset the creation date for a file
        do {
            let randomIndex = Int(arc4random_uniform(UInt32(self.fileCount)))
            self.creationResetIndex = randomIndex
            let fileName = type(of: self).fileName(for: randomIndex)
            let url = self.directory.appendingPathComponent(fileName)
            let futureDate = Date() + 60
            try! FileManager.default.setAttributes([.creationDate: futureDate], ofItemAtPath: url.path)
        }

        // reset the modification date for a file
        do {
            let randomIndex = Int(arc4random_uniform(UInt32(self.fileCount)))
            self.modifiedIndex = randomIndex
            let fileName = type(of: self).fileName(for: randomIndex)
            let url = self.directory.appendingPathComponent(fileName)
            let futureDate = Date() + 120
            try! FileManager.default.setAttributes([.modificationDate: futureDate], ofItemAtPath: url.path)
        }

        // FIXME: This vastly improves the reliability of the sort order tests
        Thread.sleep(forTimeInterval: 0.1)
    }

    override func tearDown() {
        try! FileManager.default.removeItem(at: self.directory)
    }

    func testNSFCComparableContentsSortNameAFirst() {
        do {
            let contents = try NSFileCoordinator.JSBFS_comparableContentsOfDirectory(at: self.directory,
                                                                                     sortedBy: .nameAFirst,
                                                                                     filteredBy: nil,
                                                                                     filePresenter: nil)
            XCTAssert(contents.count == self.fileCount)

            let testFirstFileName = contents.first!.fileURL.lastPathComponent
            let testLastFileName = contents.last!.fileURL.lastPathComponent
            let ogFirstFileName = type(of: self).fileName(for: 0)
            let ogLastFileName = type(of: self).fileName(for: self.fileCount - 1)
            XCTAssert(testFirstFileName == ogFirstFileName)
            XCTAssert(testLastFileName == ogLastFileName)

            let testFirstData = try Data(contentsOf: contents.first!.fileURL)
            let testLastData = try Data(contentsOf: contents.last!.fileURL)
            let ogFirstData = Data(type(of: self).fileName(for: 0).utf8)
            let ogLastData = Data(type(of: self).fileName(for: self.fileCount - 1).utf8)
            XCTAssert(testFirstData == ogFirstData)
            XCTAssert(testLastData == ogLastData)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }

    func testNSFCComparableContentsSortNameZFirst() {
        do {
            let contents = try NSFileCoordinator.JSBFS_comparableContentsOfDirectory(at: self.directory,
                                                                                     sortedBy: .nameZFirst,
                                                                                     filteredBy: nil,
                                                                                     filePresenter: nil)
            XCTAssert(contents.count == self.fileCount)

            let testFirstFileName = contents.last!.fileURL.lastPathComponent
            let testLastFileName = contents.first!.fileURL.lastPathComponent
            let ogFirstFileName = type(of: self).fileName(for: 0)
            let ogLastFileName = type(of: self).fileName(for: self.fileCount - 1)
            XCTAssert(testFirstFileName == ogFirstFileName)
            XCTAssert(testLastFileName == ogLastFileName)

            let testFirstData = try Data(contentsOf: contents.last!.fileURL)
            let testLastData = try Data(contentsOf: contents.first!.fileURL)
            let ogFirstData = Data(type(of: self).fileName(for: 0).utf8)
            let ogLastData = Data(type(of: self).fileName(for: self.fileCount - 1).utf8)
            XCTAssert(testFirstData == ogFirstData)
            XCTAssert(testLastData == ogLastData)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }

    func testNSFCComparableContentsSortModNewFirst() {
        do {
            let contents = try NSFileCoordinator.JSBFS_comparableContentsOfDirectory(at: self.directory,
                                                                                     sortedBy: .modificationNewestFirst,
                                                                                     filteredBy: nil,
                                                                                     filePresenter: nil)
            XCTAssert(contents.count == self.fileCount)

            let testFirstFileName = contents.first!.fileURL.lastPathComponent
            let testLastFileName = contents.last!.fileURL.lastPathComponent
            let ogFirstFileName = type(of: self).fileName(for: self.modifiedIndex)
            let ogLastFileName = type(of: self).fileName(for: 0)
            XCTAssert(testFirstFileName == ogFirstFileName)
            XCTAssert(testLastFileName == ogLastFileName)

            let testFirstData = try Data(contentsOf: contents.first!.fileURL)
            let testLastData = try Data(contentsOf: contents.last!.fileURL)
            let ogFirstData = Data(type(of: self).fileName(for: self.modifiedIndex).utf8)
            let ogLastData = Data(type(of: self).fileName(for: 0).utf8)
            XCTAssert(testFirstData == ogFirstData)
            XCTAssert(testLastData == ogLastData)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }

    func testNSFCComparableContentsSortModOldFirst() {
        do {
            let contents = try NSFileCoordinator.JSBFS_comparableContentsOfDirectory(at: self.directory,
                                                                                     sortedBy: .modificationOldestFirst,
                                                                                     filteredBy: nil,
                                                                                     filePresenter: nil)
            XCTAssert(contents.count == self.fileCount)

            let testFirstFileName = contents.last!.fileURL.lastPathComponent
            let testLastFileName = contents.first!.fileURL.lastPathComponent
            let ogFirstFileName = type(of: self).fileName(for: self.modifiedIndex)
            let ogLastFileName = type(of: self).fileName(for: 0)
            XCTAssert(testFirstFileName == ogFirstFileName)
            XCTAssert(testLastFileName == ogLastFileName)

            let testFirstData = try Data(contentsOf: contents.last!.fileURL)
            let testLastData = try Data(contentsOf: contents.first!.fileURL)
            let ogFirstData = Data(type(of: self).fileName(for: self.modifiedIndex).utf8)
            let ogLastData = Data(type(of: self).fileName(for: 0).utf8)
            XCTAssert(testFirstData == ogFirstData)
            XCTAssert(testLastData == ogLastData)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }

    func testNSFCComparableContentsSortCreateNewFirst() {
        do {
            let contents = try NSFileCoordinator.JSBFS_comparableContentsOfDirectory(at: self.directory,
                                                                                     sortedBy: .creationNewestFirst,
                                                                                     filteredBy: nil,
                                                                                     filePresenter: nil)
            XCTAssert(contents.count == self.fileCount)

            let testFirstFileName = contents.first!.fileURL.lastPathComponent
            let testLastFileName = contents.last!.fileURL.lastPathComponent
            let ogFirstFileName = type(of: self).fileName(for: self.creationResetIndex)
            let ogLastFileName = type(of: self).fileName(for: 0)
            XCTAssert(testFirstFileName == ogFirstFileName)
            XCTAssert(testLastFileName == ogLastFileName)

            let testFirstData = try Data(contentsOf: contents.first!.fileURL)
            let testLastData = try Data(contentsOf: contents.last!.fileURL)
            let ogFirstData = Data(type(of: self).fileName(for: self.creationResetIndex).utf8)
            let ogLastData = Data(type(of: self).fileName(for: 0).utf8)
            XCTAssert(testFirstData == ogFirstData)
            XCTAssert(testLastData == ogLastData)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }

    func testNSFCComparableContentsSortCreateOldFirst() {
        do {
            let contents = try NSFileCoordinator.JSBFS_comparableContentsOfDirectory(at: self.directory,
                                                                                     sortedBy: .creationOldestFirst,
                                                                                     filteredBy: nil,
                                                                                     filePresenter: nil)
            XCTAssert(contents.count == self.fileCount)

            let testFirstFileName = contents.last!.fileURL.lastPathComponent
            let testLastFileName = contents.first!.fileURL.lastPathComponent
            let ogFirstFileName = type(of: self).fileName(for: self.creationResetIndex)
            let ogLastFileName = type(of: self).fileName(for: 0)
            XCTAssert(testFirstFileName == ogFirstFileName)
            XCTAssert(testLastFileName == ogLastFileName)

            let testFirstData = try Data(contentsOf: contents.last!.fileURL)
            let testLastData = try Data(contentsOf: contents.first!.fileURL)
            let ogFirstData = Data(type(of: self).fileName(for: self.creationResetIndex).utf8)
            let ogLastData = Data(type(of: self).fileName(for: 0).utf8)
            XCTAssert(testFirstData == ogFirstData)
            XCTAssert(testLastData == ogLastData)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }

}
