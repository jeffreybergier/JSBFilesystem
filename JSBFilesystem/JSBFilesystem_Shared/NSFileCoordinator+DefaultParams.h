//
//  NSFileCoordinator+DefaultParams.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 9/1/18.
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

@interface NSFileCoordinator (DefaultParams)

/*!
 * @discussion Helper method with default parameters removed. Refer to documentation
 *             for the original method.
 */
+ (BOOL)JSBFS_writeData:(NSData*_Nonnull)data
                  toURL:(NSURL*_Nonnull)url
                  error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_write(_:to:));

/*!
 * @discussion Helper method with default parameters removed. Refer to documentation
 *             for the original method.
 */
+ (BOOL)JSBFS_writeFileWrapper:(NSFileWrapper*_Nonnull)fileWrapper
                         toURL:(NSURL*_Nonnull)url
                         error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_write(_:to:));

/*!
 * @discussion Helper method with default parameters removed. Refer to documentation
 *             for the original method.
 */
+ (NSData*_Nullable)JSBFS_readDataFromURL:(NSURL*_Nonnull)url
                                    error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_readData(from:));

/*!
 * @discussion Helper method with default parameters removed. Refer to documentation
 *             for the original method.
 */
+ (NSFileWrapper* _Nullable)JSBFS_readFileWrapperFromURL:(NSURL* _Nonnull)url
                                                   error:(NSError* _Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_readFileWrapper(from:));

/*!
 * @discussion Helper method with default parameters removed. Refer to documentation
 *             for the original method.
 */
+ (BOOL)JSBFS_readAndWriteDataAtURL:(NSURL*_Nonnull)url
        afterTransformdingWithBlock:(JSBFSDataTransformBlock NS_NOESCAPE _Nonnull)transform
                              error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_readAndWriteData(at:afterTransforming:));

/*!
 * @discussion Helper method with default parameters removed. Refer to documentation
 *             for the original method.
 */
+ (BOOL)JSBFS_readAndWriteFileWrapperAtURL:(NSURL*_Nonnull)url
               afterTransformdingWithBlock:(JSBFSFileWrapperTransformBlock NS_NOESCAPE _Nonnull)transform
                                     error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_readAndWriteFileWrapper(at:afterTransforming:));

/*!
 * @discussion Helper method with default parameters removed. Refer to documentation
 *             for the original method.
 */
+ (BOOL)JSBFS_deleteURL:(NSURL*_Nonnull)url
                  error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_delete(url:));

/*!
 * @discussion Helper method with default parameters removed. Refer to documentation
 *             for the original method.
 */
+ (BOOL)JSBFS_batchDeleteURLs:(NSArray<NSURL*>*_Nonnull)urls
                        error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_batchDelete(urls:));

/*!
 * @discussion Helper method with default parameters removed. Refer to documentation
 *             for the original method.
 */
+ (BOOL)JSBFS_createDirectoryAtURL:(NSURL*_Nonnull)url
                             error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_createDirectory(at:));

/*!
 * @discussion Helper method with default parameters removed. Refer to documentation
 *             for the original method.
 */
+ (JSBFSDoubleBool*_Nullable)JSBFS_fileExistsAndIsDirectoryAtURL:(NSURL*_Nonnull)url
                                                           error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_fileExistsAndIsDirectory(at:));

@end

