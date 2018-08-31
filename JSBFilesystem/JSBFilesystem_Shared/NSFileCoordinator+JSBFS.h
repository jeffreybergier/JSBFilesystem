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
 * @discussion Coordinate reading the data from the provided URL, then coordinate
 *             writing the transformed data back to the same URL.
 * @param url URL on disk to read from and to write to.
 * @param transform Block that can be used to transform the data before writing
 *                  the tranformed data back to the provided URL.
 * @param filePresenter Optional NSFilePresenter object. This will be passed to
 *        the NSFileCoordinator so that this File Presenter should not recieve
 *        requests to save the file before it can be read.
 * @param errorPtr Error parameter. Will always be populated if return is NO.
 * @return Success YES/NO.
 */
+ (BOOL)JSBFS_readAndWriteDataAtURL:(NSURL*_Nonnull)url
        afterTransformdingWithBlock:(JSBFSDataTransformBlock NS_NOESCAPE _Nonnull)transform
                      filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                              error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_readAndWriteData(at:afterTransforming:filePresenter:));

/*!
 * @discussion Coordinate reading the file wrapper from the provided URL, then
 *             coordinate writing the transformed filewrapper back to the same URL.
 * @param url URL on disk to read from and to write to.
 * @param transform Block that can be used to transform the filewrapper before
 *                  writing the tranformed filewrapper back to the provided URL.
 * @param filePresenter Optional NSFilePresenter object. This will be passed to
 *        the NSFileCoordinator so that this File Presenter should not recieve
 *        requests to save the file before it can be read.
 * @param errorPtr Error parameter. Will always be populated if return is NO.
 * @return Success YES/NO.
 */
+ (BOOL)JSBFS_readAndWriteFileWrapperAtURL:(NSURL*_Nonnull)url
               afterTransformdingWithBlock:(JSBFSFileWrapperTransformBlock NS_NOESCAPE _Nonnull)transform
                             filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                                     error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_readAndWriteFileWrapper(at:afterTransforming:filePresenter:));

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

@end
