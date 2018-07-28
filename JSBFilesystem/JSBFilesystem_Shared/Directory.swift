//
//  Directory.swift
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 23/07/2018.
//

import Foundation

public struct Directory {

    public let url: URL
    public let sort: Sort

    public init(base: FileManager.SearchPathDirectory,
                appendingPathComponent appended: String?,
                sort: Sort = Sort.default,
                createIfNeeded: Bool = true) throws
    {
        let fm = FileManager.default
        let baseURL = fm.urls(for: base, in: .userDomainMask).first!
        let url = appended != nil ? baseURL.appendingPathComponent(appended!, isDirectory: true) : baseURL
        try self.init(url: url, sort: sort, createIfNeeded: createIfNeeded)
    }

    public func subDirectory(withPathComponent pathComponent: String,
                             sort: Sort = Sort.default,
                             createIfNeeded: Bool = true) throws -> Directory
    {
        let url = self.url.appendingPathComponent(pathComponent)
        let subdirectory = try Directory(url: url, sort: sort, createIfNeeded: createIfNeeded)
        return subdirectory
    }

    internal init(url: URL, sort: Sort, createIfNeeded: Bool) throws {
        self.sort = sort
        let value = try NSFileCoordinator.JSBFS_fileExistsAndIsDirectory(at: url)
        let (isExisting, isDirectory) = (value.value1, value.value2)
        switch (isExisting, isDirectory, createIfNeeded) {
        case (true, true, _): // file exists, and is a directory, we're done
            self.url = url
            return
        case (true, false, _): // file exists but is not a directory, throw error
            throw NSError(domain: "", code: 0, userInfo: nil)
        case (false, _, true): // directory does not exist but we were asked to create it
            try NSFileCoordinator.JSBFS_createDirectory(at: url)
            self.url = url
            return
        case (false, _, false): // directory does not exist but we were asked not to create it. Throw error
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
    }

    public func count() throws -> Int {
        let count = try NSFileCoordinator.JSBFS_fileCount(inDirectoryURL: url)
        return count
    }

    public func subfileData(atIndex index: Int) throws -> URL {
        let url = try self.subfileURL(atIndex: index)
        let value = try NSFileCoordinator.JSBFS_fileExistsAndIsDirectory(at: url)
        let (isExisting, isDirectory) = (value.value1, value.value2)
        guard isExisting && !isDirectory else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        return url
    }

    public func subfileURL(atIndex index: Int) throws -> URL {
        let tupleArray = try NSFileCoordinator.JSB_directoryContentsURLsAndModificationDates(ofDirectoryURL: self.url,
                                                                                             sortedBy: self.sort.by.resourceValue,
                                                                                             ascending: sort.ascending)
        let urls = tupleArray.map({ return $0.fileURL as URL })
        return urls[index]
    }

    public struct Sort {
        public var by: By
        public var ascending: Bool
        public enum By {
            case modificationDate, creationDate, name
            public var resourceValue: URLResourceKey {
                switch self {
                case .modificationDate:
                    return .contentModificationDateKey
                case .creationDate:
                    return .creationDateKey
                case .name:
                    return .localizedNameKey
                }
            }
        }
        public static let `default` =  Sort(by: .name, ascending: true)
    }
}
