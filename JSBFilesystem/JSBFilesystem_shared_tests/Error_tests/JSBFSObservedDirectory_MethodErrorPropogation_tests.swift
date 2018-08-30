//
//  JSBFSObservedDirectory_MethodErrorPropogation_tests.swift
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/28/18.
//

import XCTest
import JSBFilesystem

class JSBFSObservedDirectory_MethodErrorPropogation_tests: JSBFSDirectory_MethodErrorPropogation_tests {

    override func setUp() {
        self.directory = try! JSBFSObservedDirectory(base: .cachesDirectory,
                                                     appendingPathComponent: UUID().uuidString,
                                                     createIfNeeded: true,
                                                     sortedBy: .nameAFirst,
                                                     filteredBy: nil,
                                                     changeKind: JSBFSObservedDirectoryChangeKind.modificationsAsInsertionsDeletions)
        // delete the directory out from under our object
        // that way its methods will produce errors
        try! FileManager.default.removeItem(at: self.directory.url)
    }
    
}
