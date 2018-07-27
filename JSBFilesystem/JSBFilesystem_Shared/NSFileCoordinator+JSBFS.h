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
