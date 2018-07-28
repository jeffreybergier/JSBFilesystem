//
//  NSFileCoordinator+JSBFS.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 27/07/2018.
//

#import "NSFileCoordinator+JSBFS.h"

@implementation NSFileCoordinator (JSBFS)

+ (BOOL)JSBFS_writeData:(NSData*)data toURL:(NSURL*)url error:(NSError**)errorPtr;
{
    NSError* outerError = nil;
    __block NSError* innerError = nil;
    __block BOOL innerSuccess = NO;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateWritingItemAtURL:url
                          options:NSFileCoordinatorWritingForReplacing
                            error:&outerError
                       byAccessor:^(NSURL * _Nonnull newURL)
    {
        innerSuccess = [data writeToURL:newURL options:NSDataWritingAtomic error:&innerError];
    }];
    if (outerError != NULL) {
        *errorPtr = outerError;
        return NO;
    } else if (innerError != NULL || !innerSuccess) {
        *errorPtr = innerError;
        return NO;
    } else {
        return YES;
    }
}

+ (NSData*)JSBFS_readDataFromURL:(NSURL*)url
                           error:(NSError**)errorPtr;
{
    NSError* outerError = nil;
    __block NSError* innerError = nil;
    __block NSData* data = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateReadingItemAtURL:url
                          options:NSFileCoordinatorReadingResolvesSymbolicLink
                            error:&outerError
                       byAccessor:^(NSURL * _Nonnull newURL)
    {
        data = [NSData dataWithContentsOfURL:newURL options:0 error:&innerError];
    }];
    if (outerError != NULL) {
        *errorPtr = outerError;
        return nil;
    } else if (innerError != NULL || data == nil) {
        *errorPtr = innerError;
        return nil;
    } else {
        return data;
    }
}

+ (BOOL)JSBFS_recursivelyDeleteDirectoryOrFileAtURL:(NSURL*)url
                                              error:(NSError**)errorPtr;
{
    NSError* outerError = nil;
    __block NSError* innerError = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateWritingItemAtURL:url
                          options:NSFileCoordinatorWritingForDeleting
                            error:&outerError
                       byAccessor:^(NSURL * _Nonnull newURL)
     {
         [[NSFileManager defaultManager] trashItemAtURL:newURL resultingItemURL:nil error:&innerError];
     }];
    if (outerError != NULL) {
        *errorPtr = outerError;
        return NO;
    } else if (innerError != NULL) {
        *errorPtr = innerError;
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)JSBFS_moveSourceFileURL:(NSURL*)sourceURL
           toDestinationFileURL:(NSURL*)destinationURL
                          error:(NSError**)errorPtr;
{
    NSError* outerError = nil;
    __block NSError* innerError = nil;
    __block BOOL innerSuccess = NO;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateReadingItemAtURL:sourceURL
                          options:0
                 writingItemAtURL:destinationURL
                          options:NSFileCoordinatorWritingForReplacing << NSFileCoordinatorWritingForMoving
                            error:&outerError
                       byAccessor:^(NSURL * _Nonnull newReadingURL, NSURL * _Nonnull newWritingURL)
     {
         NSFileManager* fm = [NSFileManager defaultManager];
         NSURL* parentDir = [newWritingURL URLByDeletingLastPathComponent];
         innerSuccess = [fm createDirectoryAtURL:parentDir withIntermediateDirectories:YES attributes:nil error:&innerError];
         if (!innerSuccess || innerError != nil) { return; }
         innerSuccess = [fm moveItemAtURL:newReadingURL toURL:newWritingURL error:&innerError];
     }];
    if (outerError != NULL) {
        *errorPtr = outerError;
        return NO;
    } else if (innerError != NULL || !innerSuccess) {
        *errorPtr = innerError;
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)JSBFS_createDirectoryAtURL:(NSURL* _Nonnull)url
                             error:(NSError* _Nullable*)errorPtr;
{
    NSError* outerError = nil;
    __block NSError* innerError = nil;
    __block BOOL innerSuccess = NO;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateWritingItemAtURL:url
                          options:NSFileCoordinatorWritingForReplacing
                            error:&outerError
                       byAccessor:^(NSURL * _Nonnull newURL)
     {
         innerSuccess = [[NSFileManager defaultManager] createDirectoryAtURL:newURL withIntermediateDirectories:YES attributes:nil error:&innerError];
     }];
    if (outerError != NULL) {
        *errorPtr = outerError;
        return NO;
    } else if (innerError != NULL || !innerSuccess) {
        *errorPtr = innerError;
        return NO;
    } else {
        return YES;
    }
}

+ (NSInteger)JSBFS_fileCountInDirectoryURL:(NSURL*)url
                                     error:(NSError**)errorPtr;
{

    __block NSError* outerError = nil;
    __block NSError* innerError = nil;
    __block NSArray<NSURL*>* contents = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateReadingItemAtURL:url
                          options:NSFileCoordinatorReadingResolvesSymbolicLink
                            error:&outerError
                       byAccessor:^(NSURL* _Nonnull newURL)
     {
         contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url
                                       includingPropertiesForKeys:nil
                                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                                            error:&outerError];
     }];
    if (outerError != NULL) {
        *errorPtr = outerError;
        return 0;
    } else if (innerError != NULL || contents == nil) {
        *errorPtr = innerError;
        return 0;
    } else {
        return [contents count];
    }
}

+ (JSBFSDoubleBool*)JSBFS_fileExistsAndIsDirectoryAtURL:(NSURL*)url error:(NSError**)errorPtr;
{
    NSError* outerError = nil;
    __block NSError* innerError = nil;
    __block JSBFSDoubleBool* value = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateReadingItemAtURL:url
                          options:NSFileCoordinatorReadingResolvesSymbolicLink
                            error:&outerError
                       byAccessor:^(NSURL* _Nonnull newURL)
     {
         BOOL isDirectory = NO;
         BOOL isExisting = [[NSFileManager defaultManager] fileExistsAtPath:[newURL path] isDirectory:&isDirectory];
         value = [[JSBFSDoubleBool alloc] initWithValue1:isExisting value2:isDirectory];
     }];
    if (outerError != NULL) {
        *errorPtr = outerError;
        return nil;
    } else if (innerError != NULL || value == nil) {
        *errorPtr = innerError;
        return nil;
    } else {
        return value;
    }
}

+ (NSArray<JSBFSFileComparison*>*)JSBFS_urlComparisonsForFilesInDirectoryURL:(NSURL* _Nonnull)directoryURL
                                                         sortedByResourceKey:(NSURLResourceKey)resourceKey
                                                            orderedAscending:(BOOL)ascending
                                                                       error:(NSError* _Nullable*)error;
{
    return nil;

//    /// Only supports URLResourceKey.localizedNameKey, .contentModificationDateKey, .creationDateKey
//    internal class func JSB_directoryContentsURLsAndModificationDates(ofDirectoryURL url: URL,
//                                                                      sortedBy: URLResourceKey,
//                                                                      ascending: Bool) throws -> [FileURLDiffer]
//    {
//        let fm = FileManager.default
//        let fileList = try fm.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
//        var errorPointer: NSErrorPointer = nil
//        var coordinatorError: Error? { return errorPointer?.pointee }
//        var readError: Error?
//        let c = NSFileCoordinator()
//        var unsortedURLs: NSArray!
//        c.prepare(forReadingItemsAt: [url] + fileList, options: [], writingItemsAt: [], options: [], error: errorPointer, byAccessor: { _ in
//            guard coordinatorError == nil else { return }
//            do {
//                unsortedURLs = try fm.contentsOfDirectory(at: url, includingPropertiesForKeys: [sortedBy], options: [.skipsHiddenFiles]) as NSArray
//            } catch {
//                readError = error
//            }
//        })
//        if let error = coordinatorError {
//            throw error
//        } else if let error = readError {
//            throw error
//        }
//        let sortedURLs: NSArray = unsortedURLs.sortedArray() { (lhs, rhs) -> ComparisonResult in
//            let lhs = lhs as! NSURL
//            let rhs = rhs as! NSURL
//            var lhsPtr: AnyObject?
//            var rhsPtr: AnyObject?
//            do {
//                try lhs.getResourceValue(&lhsPtr, forKey: sortedBy)
//                try rhs.getResourceValue(&rhsPtr, forKey: sortedBy)
//            } catch {
//                readError = error
//            }
//            switch sortedBy {
//            case .creationDateKey, .contentModificationDateKey:
//                let lhsDate = lhsPtr as! NSDate
//                let rhsDate = rhsPtr as! NSDate
//                if ascending {
//                    return lhsDate.compare(rhsDate as Date)
//                } else {
//                    return rhsDate.compare(lhsDate as Date)
//                }
//            case .localizedNameKey:
//                let lhsName = lhsPtr as! NSString
//                let rhsName = rhsPtr as! NSString
//                if ascending {
//                    return lhsName.localizedCaseInsensitiveCompare(rhsName as String)
//                } else {
//                    return rhsName.localizedCaseInsensitiveCompare(lhsName as String)
//                }
//            default:
//                fatalError("Only supports URLResourceKey.localizedNameKey, .contentModificationDateKey, .creationDateKey")
//            }
//        } as NSArray
//        let differs = sortedURLs.map() { url -> FileURLDiffer in
//            let url = url as! NSURL
//            var ptr: AnyObject?
//            do {
//                try url.getResourceValue(&ptr, forKey: .contentModificationDateKey)
//            } catch {
//                readError = error
//            }
//            let date = ptr as! NSDate
//            return FileURLDiffer(fileURL: url, modificationDate: date)
//        }
//        if let error = readError {
//            throw error
//        }
//        return differs
//    }
//}

}

@end

@implementation JSBFSDoubleBool
- (instancetype)initWithValue1:(BOOL)value1 value2:(BOOL)value2;
{
    if (self = [super init]) {
        _value1 = value1;
        _value2 = value2;
    }
    return self;
}
@end
