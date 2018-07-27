import Foundation
import IGListKit

internal class FileURLDiffer: NSObject, ListDiffable {
    internal let fileURL: NSURL
    internal let modificationDate: NSDate
    internal init(fileURL: NSURL, modificationDate: NSDate) {
        self.fileURL = fileURL
        self.modificationDate = modificationDate
        super.init()
    }
    internal func diffIdentifier() -> NSObjectProtocol {
        return self.fileURL
    }
    internal func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        // test #1 - bail if not the right object type
        guard let rhs = object as? FileURLDiffer else { return false }
        // test #2 - bail if the modification dates are different
        guard self.modificationDate.isEqual(rhs.modificationDate) else { return false }
        // test #3 - everything has passed so far, just return the final test
        return self.fileURL.isEqual(rhs.fileURL)
    }
}

internal extension NSFileCoordinator {

    internal class func JSB_fileExistsAndIsDirectory(at url: URL) throws -> (Bool, Bool) {
        var errorPointer: NSErrorPointer = nil
        var coordinatorError: Error? { return errorPointer?.pointee }
        var fileExists: Bool = false
        var isDirectory: ObjCBool = false
        let c = NSFileCoordinator()
        c.coordinate(readingItemAt: url, options: [.resolvesSymbolicLink], error: errorPointer, byAccessor: { url in
            guard coordinatorError == nil else { return }
            fileExists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        })
        if let error = coordinatorError {
            throw error
        } else {
            return (fileExists, isDirectory.boolValue)
        }
    }

    internal class func JSB_fileCountInDirectory(at url: URL) throws -> Int {
        var errorPointer: NSErrorPointer = nil
        var coordinatorError: Error? { return errorPointer?.pointee }
        var readError: Error?
        var count: Int?
        let c = NSFileCoordinator()
        c.coordinate(readingItemAt: url, options: [.resolvesSymbolicLink], error: errorPointer, byAccessor: { url in
            guard coordinatorError == nil else { return }
            do {
                count = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [], options: [.skipsHiddenFiles]).count
            } catch {
                readError = error
            }
        })
        if let error = coordinatorError {
            throw error
        } else if let error = readError {
            throw error
        } else {
            return count!
        }
    }

    /// Only supports URLResourceKey.localizedNameKey, .contentModificationDateKey, .creationDateKey
    internal class func JSB_directoryContentsURLsAndModificationDates(ofDirectoryURL url: URL,
                                                                      sortedBy: URLResourceKey,
                                                                      ascending: Bool) throws -> [FileURLDiffer]
    {
        let fm = FileManager.default
        let fileList = try fm.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        var errorPointer: NSErrorPointer = nil
        var coordinatorError: Error? { return errorPointer?.pointee }
        var readError: Error?
        let c = NSFileCoordinator()
        var unsortedURLs: NSArray!
        c.prepare(forReadingItemsAt: [url] + fileList, options: [], writingItemsAt: [], options: [], error: errorPointer, byAccessor: { _ in
            guard coordinatorError == nil else { return }
            do {
                unsortedURLs = try fm.contentsOfDirectory(at: url, includingPropertiesForKeys: [sortedBy], options: [.skipsHiddenFiles]) as NSArray
            } catch {
                readError = error
            }
        })
        if let error = coordinatorError {
            throw error
        } else if let error = readError {
            throw error
        }
        let sortedURLs: NSArray = unsortedURLs.sortedArray() { (lhs, rhs) -> ComparisonResult in
            let lhs = lhs as! NSURL
            let rhs = rhs as! NSURL
            var lhsPtr: AnyObject?
            var rhsPtr: AnyObject?
            do {
                try lhs.getResourceValue(&lhsPtr, forKey: sortedBy)
                try rhs.getResourceValue(&rhsPtr, forKey: sortedBy)
            } catch {
                readError = error
            }
            switch sortedBy {
            case .creationDateKey, .contentModificationDateKey:
                let lhsDate = lhsPtr as! NSDate
                let rhsDate = rhsPtr as! NSDate
                if ascending {
                    return lhsDate.compare(rhsDate as Date)
                } else {
                    return rhsDate.compare(lhsDate as Date)
                }
            case .localizedNameKey:
                let lhsName = lhsPtr as! NSString
                let rhsName = rhsPtr as! NSString
                if ascending {
                    return lhsName.localizedCaseInsensitiveCompare(rhsName as String)
                } else {
                    return rhsName.localizedCaseInsensitiveCompare(lhsName as String)
                }
            default:
                fatalError("Only supports URLResourceKey.localizedNameKey, .contentModificationDateKey, .creationDateKey")
            }
        } as NSArray
        let differs = sortedURLs.map() { url -> FileURLDiffer in
            let url = url as! NSURL
            var ptr: AnyObject?
            do {
                try url.getResourceValue(&ptr, forKey: .contentModificationDateKey)
            } catch {
                readError = error
            }
            let date = ptr as! NSDate
            return FileURLDiffer(fileURL: url, modificationDate: date)
        }
        if let error = readError {
            throw error
        }
        return differs
    }
}
