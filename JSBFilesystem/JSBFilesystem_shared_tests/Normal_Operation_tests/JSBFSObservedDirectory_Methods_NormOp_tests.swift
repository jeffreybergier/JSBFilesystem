//
//  JSBFSObservedDirectory_Methods_NormOp_tests.swift
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/29/18.
//

import XCTest
import JSBFilesystem

class JSBFSObservedDirectory_Methods_NormOp_tests: JSBFSDirectory_Methods_NormOp_tests {

    override func setUp() {
        self.directory = try! JSBFSObservedDirectory(base: .cachesDirectory,
                                                     appendingPathComponent: UUID().uuidString,
                                                     createIfNeeded: true,
                                                     sortedBy: .nameAFirst,
                                                     filteredBy: nil,
                                                     changeKind: .includingModifications)
        // create files
        self.makeFakeFiles()
    }
    
}
