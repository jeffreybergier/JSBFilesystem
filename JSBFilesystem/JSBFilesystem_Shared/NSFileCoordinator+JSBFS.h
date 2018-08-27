//
//  NSFileCoordinator+JSBFS.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 27/07/2018.
//
//  MIT License
//
//  Copyright (c) 2018 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//

@import Foundation;
#import "SmallTypes.h"
@class JSBFSFileComparison;
@class JSBFSDoubleBool;

// MARK: File Wrapper API - Read and Write File Wrappers

/// Refer to Docs for how to use File Packages and NSFileWrappers
/// https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/DocumentPackages/DocumentPackages.html#//apple_ref/doc/uid/10000123i-CH106-SW1
/// https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileWrappers/FileWrappers.html#//apple_ref/doc/uid/TP40010672-CH13-DontLinkElementID_5

@interface NSFileCoordinator (JSBFS)

+ (BOOL)JSBFS_writeData:(NSData* _Nonnull)data
                  toURL:(NSURL* _Nonnull)url
                  error:(NSError * _Nullable *)errorPtr
NS_SWIFT_NAME(JSBFS_write(_:to:));

+ (BOOL)JSBFS_writeFileWrapper:(NSFileWrapper* _Nonnull)fileWrapper
                         toURL:(NSURL* _Nonnull)url
                         error:(NSError * _Nullable *)errorPtr
NS_SWIFT_NAME(JSBFS_write(_:to:));

+ (NSData* _Nullable)JSBFS_readDataFromURL:(NSURL* _Nonnull)url
                                     error:(NSError* _Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_readData(from:));

+ (NSFileWrapper* _Nullable)JSBFS_readFileWrapperFromURL:(NSURL* _Nonnull)url
                                                   error:(NSError* _Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_readFileWrapper(from:));

/*!
 * @discussion Delete the directory or file at the URL. On the Mac, items will
 *             be put into the Trash. On iOS, they are deleted.
 * @param url Directory or file on disk.
 * @param filePresenter Optional NSFilePresenter object. This will be passed to
 *        the NSFileCoordinator used so the filePresenter should not be notified
 *        about the deleted files.
 * @param errorPtr Error parameter. Will always be populated if return is NO.
 * @return Success of delete.
 */
+ (BOOL)JSBFS_deleteURL:(NSURL*_Nonnull)url
          filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                  error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_delete(url:filePresenter:));

/*!
 * @discussion Delete the directories or files in the Array. On the Mac, items will
 *             be put into the Trash. On iOS, they are deleted. This operation is
 *             not atomic. Each item is deleted 1 by 1, if any item fails to
 *             delete, the whole operation is abandoned and the already deleted
 *             files are not restored.
 * @param urls Array of directories or files on disk.
 * @param filePresenter Optional NSFilePresenter object. This will be passed to
 *        the NSFileCoordinator used so the filePresenter should not be notified
 *        about the deleted files.
 * @param errorPtr Error parameter. Will always be populated if return is NO.
 * @return Success of delete.
 */
+ (BOOL)JSBFS_batchDeleteURLs:(NSArray<NSURL*>*_Nonnull)urls
                filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                        error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_batchDelete(urls:filePresenter:));

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

+   (BOOL)JSBFS_executeBlock:(void (^_Nonnull)(void))executionBlock
whileCoordinatingAccessAtURL:(NSURL* _Nonnull)url
                       error:(NSError* _Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_execute(_:whileCoordinatingAccessAt:));

/// Only supports URLResourceKey.localizedNameKey, .contentModificationDateKey, .creationDateKey
/// The filteredBy array is executed within the file coordination block
/// It is safe to read those file but not to write to them. Only read them for the purpose of testing them
/// All tests must return YES for a file to be included. If it fails even one test, it will be filtered from the results.
+ (NSArray<JSBFSFileComparison*>* _Nullable)JSBFS_urlComparisonsForFilesInDirectoryURL:(NSURL* _Nonnull)url
                                                                              sortedBy:(JSBFSDirectorySort)sortedBy
                                                                            filteredBy:(NSArray<JSBFSDirectoryFilterBlock>* _Nullable)filters
                                                                                 error:(NSError* _Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_urlComparisonsForFiles(inDirectory:sortedBy:filteredBy:));

@end
