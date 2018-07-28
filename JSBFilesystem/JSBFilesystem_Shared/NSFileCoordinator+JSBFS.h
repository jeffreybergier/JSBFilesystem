//
//  NSFileCoordinator+JSBFS.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 27/07/2018.
//

@import Foundation;
#import "JSBFSFileComparison.h"

@interface JSBFSDoubleBool: NSObject
@property BOOL value1;
@property BOOL value2;
- (instancetype)initWithValue1:(BOOL)value1 value2:(BOOL)value2;
@end

@interface NSFileCoordinator (JSBFS)

+ (BOOL)JSBFS_writeData:(NSData* _Nonnull)data
                  toURL:(NSURL* _Nonnull)url
                  error:(NSError * _Nullable *)errorPtr
NS_SWIFT_NAME(JSBFS_write(_:to:));

+ (NSData* _Nullable)JSBFS_readDataFromURL:(NSURL* _Nonnull)url error:(NSError* _Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_readData(from:));

+ (BOOL)JSBFS_recursivelyDeleteDirectoryOrFileAtURL:(NSURL* _Nonnull)url error:(NSError* _Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_recursivelyDeleteDirectoryOrFile(at:));

+ (BOOL)JSBFS_moveSourceFileURL:(NSURL* _Nonnull)sourceURL
           toDestinationFileURL:(NSURL* _Nonnull)destinationURL
                          error:(NSError* _Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_move(sourceFile:toDestinationFile:));

+ (BOOL)JSBFS_createDirectoryAtURL:(NSURL* _Nonnull)url error:(NSError* _Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_createDirectory(at:));

+ (NSInteger)JSBFS_fileCountInDirectoryURL:(NSURL* _Nonnull)url error:(NSError* _Nullable*)errorPtr
__attribute__((swift_error(nonnull_error)))
NS_SWIFT_NAME(JSBFS_fileCount(inDirectoryURL:));

/// Value1 = FileExists, Value2 = isDirectory
+ (JSBFSDoubleBool* _Nullable)JSBFS_fileExistsAndIsDirectoryAtURL:(NSURL* _Nonnull)url error:(NSError* _Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_fileExistsAndIsDirectory(at:));

/// Only supports URLResourceKey.localizedNameKey, .contentModificationDateKey, .creationDateKey
+ (NSArray<JSBFSFileComparison*>* _Nullable)JSBFS_urlComparisonsForFilesInDirectoryURL:(NSURL* _Nonnull)directoryURL
                                                         sortedByResourceKey:(NSURLResourceKey)resourceKey
                                                            orderedAscending:(BOOL)ascending
                                                                       error:(NSError* _Nullable*)error
NS_SWIFT_NAME(JSBFS_urlComparisonsForFiles(inDirectory:sortedBy:orderedAscending:));

@end
