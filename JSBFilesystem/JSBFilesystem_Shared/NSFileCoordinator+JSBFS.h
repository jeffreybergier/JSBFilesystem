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

+ (NSData* _Nullable)JSBFS_readDataFromURL:(NSURL* _Nonnull)url
                                     error:(NSError* _Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_readData(from:));

+ (BOOL)JSBFS_recursivelyDeleteDirectoryOrFileAtURL:(NSURL* _Nonnull)url
                                              error:(NSError* _Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_recursivelyDeleteDirectoryOrFile(at:));

+ (BOOL)JSBFS_moveSourceFileURL:(NSURL* _Nonnull)sourceURL
           toDestinationFileURL:(NSURL* _Nonnull)destinationURL
                          error:(NSError* _Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_move(sourceFile:toDestinationFile:));

+ (BOOL)JSBFS_createDirectoryAtURL:(NSURL* _Nonnull)url
                             error:(NSError* _Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_createDirectory(at:));

+ (NSInteger)JSBFS_fileCountInDirectoryURL:(NSURL* _Nonnull)url
                                    error:(NSError* _Nullable*)errorPtr
__attribute__((swift_error(nonnull_error)))
NS_SWIFT_NAME(JSBFS_fileCount(inDirectoryURL:));

+ (JSBFSDoubleBool*)JSBFS_fileExistsAndIsDirectoryAtURL:(NSURL*)url error:(NSError**)errorPtr;
/// Only supports URLResourceKey.localizedNameKey, .contentModificationDateKey, .creationDateKey
+ (JSBFSFileComparison*)JSBFS_urlComparisonsForFilesInDirectoryURL:(NSURL*)directoryURL
                                                          sortedBy:(NSURLResourceKey)resourceKey
                                                         ascending:(BOOL)ascending
                                                             error:(NSError**)error;

@end
