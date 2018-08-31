//
//  NSFileCoordinator_ContentSort_NormOp_tests.swift
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

class NSFileCoordinator_ContentFilter_NormOp_tests: XCTestCase {
    
    class func fileName(for index: Int) -> String {
        return String(format:"%02.0f", Float(index)) + ".testfile"
    }
    class func index(forFileName fileName: String) -> Int {
        let noAlpha = fileName.trimmingCharacters(in: .letters)
        let noDecimal = noAlpha.dropLast()
        return Int(String(noDecimal)) ?? -1
    }
    
    var directory: URL!
    let fileCount = 20
    let divisor = 2
    
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
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: self.directory)
    }
    
    func testNSFCContentEveryOtherSingleFilterSortedNameAFirst() {
        do {
            let filter: @convention(block) (URL) -> Bool = { url -> Bool in
                let index = type(of:self).index(forFileName: url.lastPathComponent)
                return index % self.divisor == 0
            }
            let contents = try NSFileCoordinator.JSBFS_contentsOfDirectory(at: self.directory,
                                                                           sortedBy: .nameAFirst,
                                                                           filteredBy: [filter],
                                                                           filePresenter: nil)
            XCTAssert(contents.count == self.fileCount / self.divisor)
            
            let testFirstFileName = contents.first!.lastPathComponent
            let ogFirstFileName = type(of: self).fileName(for: 0)
            XCTAssert(testFirstFileName == ogFirstFileName)
            
            let testFirstData = try Data(contentsOf: contents.first!)
            let ogFirstData = Data(type(of: self).fileName(for: 0).utf8)
            XCTAssert(testFirstData == ogFirstData)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }
    
    func testNSFCContentEveryOtherSingleFilterSortedNameZFirst() {
        do {
            let filter: @convention(block) (URL) -> Bool = { url -> Bool in
                let index = type(of:self).index(forFileName: url.lastPathComponent)
                return index % self.divisor == 0
            }
            let contents = try NSFileCoordinator.JSBFS_contentsOfDirectory(at: self.directory,
                                                                           sortedBy: .nameZFirst,
                                                                           filteredBy: [filter],
                                                                           filePresenter: nil)
            XCTAssert(contents.count == self.fileCount / self.divisor)
            
            let testFirstFileName = contents.last!.lastPathComponent
            let ogFirstFileName = type(of: self).fileName(for: 0)
            XCTAssert(testFirstFileName == ogFirstFileName)
            
            let testFirstData = try Data(contentsOf: contents.last!)
            let ogFirstData = Data(type(of: self).fileName(for: 0).utf8)
            XCTAssert(testFirstData == ogFirstData)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }
    
    func testNSFCContentTripleFilterExcludeAllLast() {
        do {
            var filterTriggerd = 0
            let filters: [@convention(block) (URL) -> Bool] =
                [
                    { _ in
                        filterTriggerd += 1
                        return true
                    },
                    { _ in
                        filterTriggerd += 1
                        return true
                    },
                    { _ in
                        filterTriggerd += 1
                        return false
                    }
            ]
            let contents = try NSFileCoordinator.JSBFS_contentsOfDirectory(at: self.directory,
                                                                           sortedBy: .nameZFirst,
                                                                           filteredBy: filters,
                                                                           filePresenter: nil)
            XCTAssert(contents.count == 0)
            XCTAssert(filterTriggerd == self.fileCount * filters.count)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }
    
    func testNSFCContentTripleFilterExcludeAllFirst() {
        do {
            let filters: [@convention(block) (URL) -> Bool] =
                [
                    { _ in
                        return false
                    },
                    { _ in
                        XCTFail()
                        return true
                    },
                    { _ in
                        XCTFail()
                        return true
                    }
            ]
            let contents = try NSFileCoordinator.JSBFS_contentsOfDirectory(at: self.directory,
                                                                           sortedBy: .nameZFirst,
                                                                           filteredBy: filters,
                                                                           filePresenter: nil)
            XCTAssert(contents.count == 0)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }
    
    func testNSFCComparableContentEveryOtherSingleFilterSortedNameAFirst() {
        do {
            let filter: @convention(block) (URL) -> Bool = { url -> Bool in
                let index = type(of:self).index(forFileName: url.lastPathComponent)
                return index % self.divisor == 0
            }
            let contents = try NSFileCoordinator.JSBFS_comparableContentsOfDirectory(at: self.directory,
                                                                                     sortedBy: .nameAFirst,
                                                                                     filteredBy: [filter],
                                                                                     filePresenter: nil)
            XCTAssert(contents.count == self.fileCount / self.divisor)
            
            let testFirstFileName = contents.first!.fileURL.lastPathComponent
            let ogFirstFileName = type(of: self).fileName(for: 0)
            XCTAssert(testFirstFileName == ogFirstFileName)
            
            let testFirstData = try Data(contentsOf: contents.first!.fileURL)
            let ogFirstData = Data(type(of: self).fileName(for: 0).utf8)
            XCTAssert(testFirstData == ogFirstData)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }
    
    func testNSFCComparableContentEveryOtherSingleFilterSortedNameZFirst() {
        do {
            let filter: @convention(block) (URL) -> Bool = { url -> Bool in
                let index = type(of:self).index(forFileName: url.lastPathComponent)
                return index % self.divisor == 0
            }
            let contents = try NSFileCoordinator.JSBFS_comparableContentsOfDirectory(at: self.directory,
                                                                                     sortedBy: .nameZFirst,
                                                                                     filteredBy: [filter],
                                                                                     filePresenter: nil)
            XCTAssert(contents.count == self.fileCount / self.divisor)
            
            let testFirstFileName = contents.last!.fileURL.lastPathComponent
            let ogFirstFileName = type(of: self).fileName(for: 0)
            XCTAssert(testFirstFileName == ogFirstFileName)
            
            let testFirstData = try Data(contentsOf: contents.last!.fileURL)
            let ogFirstData = Data(type(of: self).fileName(for: 0).utf8)
            XCTAssert(testFirstData == ogFirstData)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }
    
    func testNSFCComparableContentTripleFilterExcludeAllLast() {
        do {
            var filterTriggerd = 0
            let filters: [@convention(block) (URL) -> Bool] =
                [
                    { _ in
                        filterTriggerd += 1
                        return true
                    },
                    { _ in
                        filterTriggerd += 1
                        return true
                    },
                    { _ in
                        filterTriggerd += 1
                        return false
                    }
            ]
            let contents = try NSFileCoordinator.JSBFS_comparableContentsOfDirectory(at: self.directory,
                                                                                     sortedBy: .nameZFirst,
                                                                                     filteredBy: filters,
                                                                                     filePresenter: nil)
            XCTAssert(contents.count == 0)
            XCTAssert(filterTriggerd == self.fileCount * filters.count)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }
    
    func testNSFCComparableContentTripleFilterExcludeAllFirst() {
        do {
            let filters: [@convention(block) (URL) -> Bool] =
                [
                    { _ in
                        return false
                    },
                    { _ in
                        XCTFail()
                        return true
                    },
                    { _ in
                        XCTFail()
                        return true
                    }
            ]
            let contents = try NSFileCoordinator.JSBFS_comparableContentsOfDirectory(at: self.directory,
                                                                                     sortedBy: .nameZFirst,
                                                                                     filteredBy: filters,
                                                                                     filePresenter: nil)
            XCTAssert(contents.count == 0)
        } catch {
            let e = String(describing: error)
            XCTFail(e)
        }
    }
}
