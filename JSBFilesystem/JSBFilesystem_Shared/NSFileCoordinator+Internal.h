//
//  NSFileCoordinator+Internal.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/30/18.
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
typedef NS_ENUM(NSInteger, JSBFSDirectorySort);

@interface NSFileCoordinator (Internal)

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

@end
