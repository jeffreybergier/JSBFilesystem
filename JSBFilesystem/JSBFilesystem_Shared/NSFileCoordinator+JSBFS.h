//
//  NSFileCoordinator+JSBFS.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 27/07/2018.
//

@import Foundation;

@interface JSBFSDoubleBool: NSObject
@property BOOL value1;
@property BOOL value2;
- (instancetype)initWithValue1:(BOOL)value1 value2:(BOOL)value2;
@end

@interface JSBFSFileComparison: NSObject
@property (readonly, nonatomic, strong) NSURL* fileURL;
@property (readonly, nonatomic, strong) NSDate* modificationDate;
- (instancetype)initWithFileURL:(NSURL*)fileURL modificationDate:(NSDate*)modificationDate;
@end

@interface NSFileCoordinator (JSBFS)

+ (BOOL)JSBFS_writeData:(NSData*)data toURL:(NSURL*)url error:(NSError**)errorPtr;
+ (NSData*)JSBFS_readDataFromURL:(NSURL*)url error:(NSError**)errorPtr;
+ (BOOL)JSBFS_recursivelyDeleteDirectoryOrFileAtURL:(NSURL*)url error:(NSError**)errorPtr;
+ (BOOL)JSBFS_moveFileOrDirectoryFromSourceURL:(NSURL*)sourceURL toDestinationURL:(NSURL*)destinationURL error:(NSError**)errorPtr;
+ (BOOL)JSBFS_createDirectoryAtURL:(NSURL*)url error:(NSError**)errorPtr;
+ (NSInteger)JSBFS_fileCountInDirectoryURL:(NSURL*)directoryURL error:(NSError**)errorPtr;
+ (JSBFSDoubleBool*)JSBFS_fileExistsAndIsDirectoryAtURL:(NSURL*)url error:(NSError**)errorPtr;
/// Only supports URLResourceKey.localizedNameKey, .contentModificationDateKey, .creationDateKey
+ (JSBFSFileComparison*)JSBFS_urlComparisonsForFilesInDirectoryURL:(NSURL*)directoryURL
                                                          sortedBy:(NSURLResourceKey)resourceKey
                                                         ascending:(BOOL)ascending
                                                             error:(NSError**)error;

@end


/*
internal extension NSFileCoordinator {

    internal class func JSB_write(data: Data, to url: URL) throws

    internal class func JSB_createDirectory(at url: URL) throws

    internal class func JSB_read(from url: URL) throws -> Data

    internal class func JSB_fileExistsAndIsDirectory(at url: URL) throws -> (Bool, Bool)

    internal class func JSB_delete(at url: URL) throws

    internal class func JSB_move(from source: URL, to destination: URL) throws

    internal class func JSB_fileCountInDirectory(at url: URL) throws -> Int

    /// Only supports URLResourceKey.localizedNameKey, .contentModificationDateKey, .creationDateKey
    internal class func JSB_directoryContentsURLsAndModificationDates(ofDirectoryURL url: URL, sortedBy: URLResourceKey, ascending: Bool) throws -> [FileURLDiffer]
}
*/
