import Foundation

internal extension NSFileCoordinator {

    internal class func JSB_write(data: Data, to url: URL) throws {
        var errorPointer: NSErrorPointer = nil
        var coordinatorError: Error? { return errorPointer?.pointee }
        var writeError: Error?
        let c = NSFileCoordinator()
        c.coordinate(writingItemAt: url, options: .forReplacing, error: errorPointer, byAccessor: { url in
            guard coordinatorError == nil else { return }
            do {
                try data.write(to: url)
            } catch {
                writeError = error
            }
        })
        if let error = coordinatorError {
            throw error
        } else if let error = writeError {
            throw error
        } else {
            return
        }
    }

    internal class func JSB_createDirectory(at url: URL) throws {
        var errorPointer: NSErrorPointer = nil
        var coordinatorError: Error? { return errorPointer?.pointee }
        var writeError: Error?
        let c = NSFileCoordinator()
        c.coordinate(writingItemAt: url, options: .forReplacing, error: errorPointer, byAccessor: { url in
            guard coordinatorError == nil else { return }
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                writeError = error
            }
        })
        if let error = coordinatorError {
            throw error
        } else if let error = writeError {
            throw error
        } else {
            return
        }
    }

    internal class func JSB_read(from url: URL) throws -> Data {
        var errorPointer: NSErrorPointer = nil
        var coordinatorError: Error? { return errorPointer?.pointee }
        var readError: Error?
        var data: Data?
        let c = NSFileCoordinator()
        c.coordinate(readingItemAt: url, options: [.resolvesSymbolicLink], error: errorPointer, byAccessor: { url in
            guard coordinatorError == nil else { return }
            do {
                data = try Data(contentsOf: url)
            } catch {
                readError = error
            }
        })
        if let error = coordinatorError {
            throw error
        } else if let error = readError {
            throw error
        } else {
            return data!
        }
    }

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

    internal class func JSB_delete(at url: URL) throws {
        var errorPointer: NSErrorPointer = nil
        var coordinatorError: Error? { return errorPointer?.pointee }
        var writeError: Error?
        let c = NSFileCoordinator()
        c.coordinate(writingItemAt: url, options: .forDeleting, error: errorPointer, byAccessor: { url in
            guard coordinatorError == nil else { return }
            do {
                try FileManager.default.trashItem(at: url, resultingItemURL:  nil)
            } catch {
                writeError = error
            }
        })
        if let error = coordinatorError {
            throw error
        } else if let error = writeError {
            throw error
        } else {
            return
        }
    }

    internal class func JSB_move(from source: URL, to destination: URL) throws {
        var errorPointer: NSErrorPointer = nil
        var coordinatorError: Error? { return errorPointer?.pointee }
        var moveError: Error?
        let c = NSFileCoordinator()
        c.prepare(forReadingItemsAt: [source], options: [], writingItemsAt: [source, destination], options: [.forMoving, .forReplacing], error: errorPointer, byAccessor: { _ in
            /*
             In most cases, passing the same reading and writing options to both this method and the contained coordination operations is redundant. For example, it is often appropriate to pass withoutChanges to nested read operations. This method has already triggered a call to savePresentedItemChanges(completionHandler:). The individual read operations do not need to trigger additional calls.
             */
            guard coordinatorError == nil else { return }
            c.coordinate(writingItemAt: destination, options: [], error: errorPointer, byAccessor: { url in
                guard coordinatorError == nil else { return }
                do {
                    let fm = FileManager.default
                    try fm.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                    try fm.moveItem(at: source, to: destination)
                } catch {
                    moveError = error
                }
            })
        })
        if let error = coordinatorError {
            throw error
        } else if let error = moveError {
            throw error
        } else {
            return
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
    internal class func JSB_directoryContentsURLsAndModificationDates(ofDirectoryURL url: URL, sortedBy: URLResourceKey, ascending: Bool) throws -> [(URL, Date)] {
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
            var lhsPtr: AnyObject!
            var rhsPtr: AnyObject!
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
        let tupleArray = sortedURLs.map() { url -> (URL, Date) in
            let url = url as! NSURL
            var ptr: AnyObject!
            do {
                try url.getResourceValue(&ptr, forKey: .contentModificationDateKey)
            } catch {
                readError = error
            }
            let date = ptr as! NSDate
            return (url as URL, date as Date)
        }
        if let error = readError {
            throw error
        }
        return tupleArray
    }
}
