//
//  JSBFSUnobservedDirectory.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 30/07/2018.
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

/*!
 * @discussion An object that attempts to turn a directory into a basic Array
 *             or basic database query. Use filtering, sorting, and methods on
 *             this class in order to treat a directory on the filesystem as a
 *             place to read and write, structured data.
 */
@interface JSBFSDirectory: NSObject

/*!
 * @discussion The directory URL that this object monitors.
 */
@property (readonly, nonatomic, strong) NSURL* _Nonnull url;
/*!
 * @discussion An array of filter blocks that can be used to filter contents from
 * -contentsCount:error: and other methods on this object.
 * @discussion Can be NIL or empty
 * @discussion Modifying may result in internal caches being reset
 */
@property (nonatomic, strong) NSArray<JSBFSDirectoryFilterBlock>* _Nullable filteredBy;
/*!
 * @discussion Specifies the order the files are sorted in.
 * @discussion Modifying may result in internal caches being reset
 */
@property (nonatomic) JSBFSDirectorySort sortedBy;

// MARK: init

- (instancetype)init NS_UNAVAILABLE;

/*!
 * @discussion Convenience Initializer that takes a base directory from NSFileManager
 * and appends a path component to it to make specify the final directory
 * @discussion This initializer is useful if your intent is to read and write
 * from a cache, documents, or other common directory location.
 * @param base The base directory where you would like your directory.
 * @param pathComponent Path component string appended to the base
 *        to specify the final directory location.
 * @param create Whether this initializer should attempt
 *        to create the specified directory if it does not exist.
 * @param sortedBy Order directory contents should be sorted in.
 * @param filters An array of filter blocks that can filter out files
 *        in the directory. Can be NIL or empty.
 * @param errorPtr Error parameter. Will always be populated if return is NIL.
 * @return New instance or NIL. If NIL, errorPtr will be populated.
 */
- (instancetype _Nullable)initWithBase:(NSSearchPathDirectory)base
                appendingPathComponent:(NSString* _Nullable)pathComponent
                        createIfNeeded:(BOOL)create
                              sortedBy:(JSBFSDirectorySort)sortedBy
                            filteredBy:(NSArray<JSBFSDirectoryFilterBlock>* _Nullable)filters
                                 error:(NSError*_Nullable*)errorPtr;
/*!
 * @discussion Designated initializer that takes a directory URL.
 * @discussion Exception will be thrown if a file exists at the URL that is not a directory.
 * @param url The specified URL.
 *        to specify the final directory location.
 * @param create Whether this initializer should attempt
 *        to create the specified directory if it does not exist.
 * @param sortedBy Order directory contents should be sorted in.
 * @param filters An array of filter blocks that can filter out files
 *        in the directory. Can be NIL or empty.
 * @param errorPtr Error parameter. Will always be populated if return is NIL.
 * @return New instance or NIL. If NIL, errorPtr will be populated.
 */
- (instancetype _Nullable)initWithDirectoryURL:(NSURL* _Nonnull)url
                                createIfNeeded:(BOOL)create
                                      sortedBy:(JSBFSDirectorySort)sortedBy
                                    filteredBy:(NSArray<JSBFSDirectoryFilterBlock>* _Nullable)filters
                                         error:(NSError*_Nullable*)errorPtr
NS_DESIGNATED_INITIALIZER;

// MARK: Basic API

/*!
 * @discussion Counts the number of items in the monitored directory.
 *             Uses filters array to filter items before returning count.
 * @param errorPtr Error parameter. Will always be populated if return is NSNotFound.
 * @return Directory count after filters applied or NSNotFound if there is an error.
 */
- (NSUInteger)contentsCount:(NSError*_Nullable*)errorPtr __attribute__((swift_error(nonnull_error)));

/*!
 * @discussion Finds the URL at the given index after applying filters and sorting.
 * @discussion Once a URL is retrieved, use helper methods on NSFileCoordinator
 *             to coordinate reading from and writing to the URL safely.
 * @param errorPtr Error parameter. Will always be populated if return is NIL.
 * @return URL at the given index or NIL if there is an error.
 */
- (NSURL*_Nullable)urlAtIndex:(NSUInteger)index error:(NSError*_Nullable*)errorPtr;

// MARK: Advanced API

/*!
 * @discussion Deletes all the contents after applying filters
 * @discussion This is very useful if the monitored directory is a cache
 *             and the cache needs to be deleted before re-populating it
 * @discussion Depending on filters, may not delete all contents of the directory.
 * @discussion Delete is not atomic, if there is an error mid-delete, the operation
 *             will halt and not restore already deleted files.
 * @param errorPtr Error parameter. Will always be populated if return is NO
 * @return YES if the delete succeeded, NO if there was an error.
 */
- (BOOL)deleteContents:(NSError*_Nullable*)errorPtr;

/*!
 * @discussion Find the index of a given URL after filtering and sorting.
 * @param errorPtr Error parameter will always be populated if return is NSNotFound.
 *        This is done to make Swift Error handling better for this method.
 * @return Index of item or NSNotFound if there is an error.
 */
- (NSUInteger)indexOfItemWithURL:(NSURL*_Nonnull)rhs error:(NSError*_Nullable*)errorPtr
__attribute__((swift_error(nonnull_error)));

// MARK: Internal API

- (NSArray<NSURL*>*_Nullable)sortedAndFilteredContents:(NSError*_Nullable*)errorPtr;
- (NSArray<JSBFSFileComparison*>*_Nonnull)sortedAndFilteredComparisons:(NSError*_Nullable*)errorPtr;

@end
