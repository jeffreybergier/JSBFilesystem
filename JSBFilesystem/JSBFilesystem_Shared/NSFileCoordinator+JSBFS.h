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

@interface NSFileCoordinator (JSBFS)

/*!
 * @discussion Write data to the specified URL.
 * @param data Data to write
 * @param url URL on disk to write to.
 * @param filePresenter Optional NSFilePresenter object. This will be passed to
 *        the NSFileCoordinator so that this File Presenter should not recieve
 *        updates for the changes made in this method.
 * @param errorPtr Error parameter. Will always be populated if return is NO.
 * @return Success of writing.
 */
+ (BOOL)JSBFS_writeData:(NSData*_Nonnull)data
                  toURL:(NSURL*_Nonnull)url
          filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                  error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_write(_:to:filePresenter:));

/*!
 * @discussion Write Filewrapper to the specified URL.
 * @param fileWrapper Filewrapper to write
 * @param url URL on disk to write to.
 * @param filePresenter Optional NSFilePresenter object. This will be passed to
 *        the NSFileCoordinator so that this File Presenter should not recieve
 *        updates for the changes made in this method.
 * @param errorPtr Error parameter. Will always be populated if return is NO.
 * @return Success of writing.
 */
+ (BOOL)JSBFS_writeFileWrapper:(NSFileWrapper*_Nonnull)fileWrapper
                         toURL:(NSURL*_Nonnull)url
                 filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                         error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_write(_:to:filePresenter:));

/*!
 * @discussion Read data from the URL.
 * @param url URL on disk to read from.
 * @param filePresenter Optional NSFilePresenter object. This will be passed to
 *        the NSFileCoordinator so that this File Presenter should not recieve
 *        requests to save the file before it can be read.
 * @param errorPtr Error parameter. Will always be populated if return is NIL.
 * @return Data or NIL.
 */
+ (NSData*_Nullable)JSBFS_readDataFromURL:(NSURL*_Nonnull)url
                            filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                                     error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_readData(from:filePresenter:));

/*!
 * @discussion Read file wrapper from the URL.
 * @param url URL on disk to read from.
 * @param filePresenter Optional NSFilePresenter object. This will be passed to
 *        the NSFileCoordinator so that this File Presenter should not recieve
 *        requests to save the file before it can be read.
 * @param errorPtr Error parameter. Will always be populated if return is NIL.
 * @return FileWrapper or NIL.
 */
+ (NSFileWrapper* _Nullable)JSBFS_readFileWrapperFromURL:(NSURL* _Nonnull)url
                                           filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                                                   error:(NSError* _Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_readFileWrapper(from:filePresenter:));

/*!
 * @discussion Delete the directory or file at the URL. On the Mac, items will
 *             be put into the Trash. On iOS, they are deleted.
 * @param url Directory or file on disk.
 * @param filePresenter Optional NSFilePresenter object. This will be passed to
 *        the NSFileCoordinator so that this File Presenter should not recieve
 *        updates for the changes made in this method.
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
 *        the NSFileCoordinator so that this File Presenter should not recieve
 *        updates for the changes made in this method.
 * @param errorPtr Error parameter. Will always be populated if return is NO.
 * @return Success of delete.
 */
+ (BOOL)JSBFS_batchDeleteURLs:(NSArray<NSURL*>*_Nonnull)urls
                filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                        error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_batchDelete(urls:filePresenter:));

/*!
 * @discussion Create a new directory at the specified URL. This method uses
 *             -[NSFileManager createDirectoryAtURL:withIntermediateDirectories:attributes:error:]
 *             and therefore has all of its behaviors. Create intermediate
 *             directories is set to YES.
 * @param url Location of desired new directory.
 * @param filePresenter Optional NSFilePresenter object. This will be passed to
 *        the NSFileCoordinator so that this File Presenter should not recieve
 *        updates for the changes made in this method.
 * @param errorPtr Error parameter. Will always be populated if return is NO.
 * @return Success of directory creation.
 */
+ (BOOL)JSBFS_createDirectoryAtURL:(NSURL*_Nonnull)url
                     filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                             error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_createDirectory(at:filePresenter:));

/*!
 * @discussion Read the contents of a directory.
 * @param url Directory to read from
 * @param sortedBy Desired sort order of contents
 * @param filters Optional Array of blocks to filter items out of the
 *        returned contents.
 * @param filePresenter Optional NSFilePresenter object. This will be passed to
 *        the NSFileCoordinator so that this File Presenter should not recieve
 *        requests to save the file before it can be read.
 * @param errorPtr Error parameter. Will always be populated if return is NIL.
 * @return NSArray<NSURL> or NIL.
 */
+ (NSArray<NSURL*>*_Nullable)JSBFS_contentsOfDirectoryAtURL:(NSURL*_Nonnull)url
                                                   sortedBy:(JSBFSDirectorySort)sortedBy
                                                 filteredBy:(NSArray<JSBFSDirectoryFilterBlock>*_Nullable)filters
                                              filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                                                      error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_contentsOfDirectory(at:sortedBy:filteredBy:filePresenter:));

/*!
 * @discussion Read the contents of a directory and convert them to JSBFSFileComparison objects.
 * @param url Directory to read from
 * @param sortedBy Desired sort order of contents
 * @param filters Optional Array of blocks to filter items out of the
 *        returned contents.
 * @param filePresenter Optional NSFilePresenter object. This will be passed to
 *        the NSFileCoordinator so that this File Presenter should not recieve
 *        requests to save the file before it can be read.
 * @param errorPtr Error parameter. Will always be populated if return is NIL.
 * @return NSArray<JSBFSFileComparison> or NIL.
 */
+ (NSArray<JSBFSFileComparison*>* _Nullable)JSBFS_comparableContentsOfDirectoryAtURL:(NSURL*_Nonnull)url
                                                                            sortedBy:(JSBFSDirectorySort)sortedBy
                                                                          filteredBy:(NSArray<JSBFSDirectoryFilterBlock>*_Nullable)filters
                                                                       filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                                                                               error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_comparableContentsOfDirectory(at:sortedBy:filteredBy:filePresenter:));

/*!
 * @discussion Read a URL and determine whether it exists and if its a directory.
 * @param url Directory to read from
 * @param filePresenter Optional NSFilePresenter object. This will be passed to
 *        the NSFileCoordinator so that this File Presenter should not recieve
 *        requests to save the directory before it can be read.
 * @param errorPtr Error parameter. Will always be populated if return is NIL.
 * @return JSBFSDoubleBool where value1 is fileExists and value2 is isDirectory or NIL.
 */
+ (JSBFSDoubleBool*_Nullable)JSBFS_fileExistsAndIsDirectoryAtURL:(NSURL*_Nonnull)url
                                                   filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                                                           error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_fileExistsAndIsDirectory(at:filePresenter:));

/*!
 * @discussion Ask NSFileCoordinator to read the file at the specified URL and
 *             then execute the provided block while coordinating the read.
 * @param executionBlock Block to execute while coordinating the file read.
 * @param url Directory to read from.
 * @param filePresenter Optional NSFilePresenter object. This will be passed to
 *        the NSFileCoordinator so that this File Presenter should not recieve
 *        requests to save the directory before it can be read.
 * @param errorPtr Error parameter. Will always be populated if return is NIL.
 * @return JSBFSDoubleBool where value1 is fileExists and value2 is isDirectory or NIL.
 */
+   (BOOL)JSBFS_executeBlock:(void (^_Nonnull)(void))executionBlock
whileCoordinatingAccessAtURL:(NSURL* _Nonnull)url
               filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                       error:(NSError* _Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_execute(_:whileCoordinatingAccessAt:filePresenter:));

@end
