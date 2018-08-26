//
//  JSBFSDirectoryObserver.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 28/07/2018.
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
#import "JSBFSDirectoryChanges.h"
#import "JSBFSDirectory.h"

/*!
 * @discussion Specifies whether updates from JSBFSObservedDirectory should
 *             include modifications in the diff. When modifications are not
 *             included, they appear as a matching set of insertions and deletions
 * @discussion Certain types of collection views support modifications in their
 *             batch update methods and others do not. E.G. UITableView does
 *             but UICollectionView does not.
 */
typedef NS_ENUM(NSInteger, JSBFSObservedDirectyChangeKind) {
    JSBFSObservedDirectyChangeKindIncludingModifications,
    JSBFSObservedDirectyChangeKindModificationsAsInsertionsDeletions,
};

typedef void(^JSBFSObservedDirectoryChangeBlock)(JSBFSDirectoryChanges* _Nonnull changes);

/*!
 * @discussion An object that attempts to turn a directory into a basic Array
 *             or basic database query. Use filtering, sorting, and methods on
 *             this class in order to treat a directory on the filesystem as a
 *             place to read and write, structured data.
 * @discussion This object subclass also monitors changes in the directory with
 *             NSFilePresenter. When the changesObserved block is NIL, this object
 *             behaves exactly as its superclass does. When changesObserved is
 *             set, this object speeds up enormously because it caches state internally.
 * @discussion When the changesObserved block is set, this object begins observing
 *             changes to the directory. When a change occurs, the change is diffed
 *             and the changesObserved block is executed with the changes. This is
 *             ideal when displaying the contents of the directory in a
 *             TableView or CollectionView.
 */
@interface JSBFSObservedDirectory: JSBFSDirectory <NSFilePresenter>

/*!
 * @discussion Always called on the main thread.
 * @discussion When the changesObserved block is NIL, this object
 *             behaves exactly as its superclass does. When changesObserved is
 *             set, this object speeds up enormously because it caches state internally.
 * @discussion When the changesObserved block is set, this object begins observing
 *             changes to the directory. When a change occurs, the change is diffed
 *             and the changesObserved block is executed with the changes. This is
 *             ideal when displaying the contents of the directory in a
 *             TableView or CollectionView.
 * @discussion If changeKind is set to JSBFSObservedDirectyChangeKindModificationsAsInsertionsDeletions
 *             then the object provided in the block is of type JSBFSDirectoryChanges
 *             If changeKind is set to JSBFSObservedDirectyChangeKindIncludingModifications
 *             then the object provided in the block is of type JSBFSDirectoryChangesFull
 * @discussion NSFilePresenter holds a strong reference to registered objects.
 *             In order to prevent memory leaks, the changesObserved property must
 *             be set to NIL so that the object can de-register itself.
 *             Only then can it be deallocated by ARC.
 */
@property (nonatomic, strong) JSBFSObservedDirectoryChangeBlock _Nullable changesObserved;

/*!
 * @discussion Sets a waiting timer for updates from the filesystem. NSFilePresenter
 *             Can sometimes send many updates per second. This can cause performance
 *             issues because filtering, sorting, and diffing the contents can
 *             be expensive. Increase this timer to delay how often that happens.
 */
@property (nonatomic) NSTimeInterval updateDelay;

/*!
 * @discussion Specifies the format of changes received in the changesObserved block.
 *             Refer to the documentation for JSBFSObservedDirectyChangeKind for
 *             help deciding which option works best for your application.
 */
@property (nonatomic) JSBFSObservedDirectyChangeKind changeKind;

/*!
 * @discussion NSFilePresenter protocol conformance requirement.
 * @discussion This URL always matches the -[JSBDirectory url].
 */
@property (nullable, readonly, copy, nonatomic) NSURL *presentedItemURL;

/*!
 * @discussion NSFilePresenter protocol conformance requirement.
 * @discussion Updates, filtering, sorting, and diffing are performed on the
 *             underlying DispatchQueue of this Operation Queue. Use the
 *             underlying queue to add work to the serial queue.
 */
@property (readonly, strong, nonatomic) NSOperationQueue *presentedItemOperationQueue;

- (instancetype)init
NS_UNAVAILABLE;
- (instancetype _Nullable)initWithBase:(NSSearchPathDirectory)base
                appendingPathComponent:(NSString* _Nullable)pathComponent
                        createIfNeeded:(BOOL)create
                              sortedBy:(JSBFSDirectorySort)sortedBy
                            filteredBy:(NSArray<JSBFSDirectoryFilterBlock>* _Nullable)filters
                                 error:(NSError*_Nullable*)errorPtr
NS_UNAVAILABLE;
- (instancetype _Nullable)initWithDirectoryURL:(NSURL* _Nonnull)url
                                createIfNeeded:(BOOL)create
                                      sortedBy:(JSBFSDirectorySort)sortedBy
                                    filteredBy:(NSArray<JSBFSDirectoryFilterBlock>* _Nullable)filters
                                         error:(NSError*_Nullable*)errorPtr
NS_UNAVAILABLE;

/*!
 * @discussion Convenience initializer that takes a directory URL.
 * @discussion Exception will be thrown if a file exists at the URL that is not a directory.
 * @param url The specified URL.
 *        to specify the final directory location.
 * @param create Whether this initializer should attempt
 *        to create the specified directory if it does not exist.
 * @param sortedBy Order directory contents should be sorted in.
 * @param filters An array of filter blocks that can filter out files
 *        in the directory. Can be NIL or empty.
 * @param changeKind Specifies the type of change object you would like to receive
 *        in the changesObserved block.
 * @param errorPtr Error parameter. Will always be populated if return is NIL.
 * @return New instance or NIL. If NIL, errorPtr will be populated.
 */
- (instancetype _Nullable)initWithDirectoryURL:(NSURL* _Nonnull)url
                                createIfNeeded:(BOOL)create
                                      sortedBy:(JSBFSDirectorySort)sortedBy
                                    filteredBy:(NSArray<JSBFSDirectoryFilterBlock>* _Nullable)filters
                                    changeKind:(JSBFSObservedDirectyChangeKind)changeKind
                                         error:(NSError* _Nullable*)errorPtr;

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
 * @param changeKind Specifies the type of change object you would like to receive
 *        in the changesObserved block.
 * @param errorPtr Error parameter. Will always be populated if return is NIL.
 * @return New instance or NIL. If NIL, errorPtr will be populated.
 */
- (instancetype _Nullable)initWithBase:(NSSearchPathDirectory)base
                appendingPathComponent:(NSString* _Nullable)pathComponent
                        createIfNeeded:(BOOL)create
                              sortedBy:(JSBFSDirectorySort)sortedBy
                            filteredBy:(NSArray<JSBFSDirectoryFilterBlock>* _Nullable)filters
                            changeKind:(JSBFSObservedDirectyChangeKind)changeKind
                                 error:(NSError*_Nullable*)errorPtr;

/*!
 * @discussion Forces this object to re-read, sort, filter, and diff the
 *             contents of the observed directory. If there are changes, the
 *             the changesObserved block will fire.
 */
- (void)forceUpdate;

/*!
 * @discussion Executes the provided block while the object ignores
 *             NSFilePresenter updates. After the closure executes, -forceUpdate
 *             is called so that your application can update the UI based on
 *             changes made during the batch update.
 * @discussion Note that the block is not coordinated with NSFileCoordinator.
 *             Use the helper methods on NSFileCoordinator to coordinate
 *             reading and writing data safely.
 */
- (void)performBatchUpdates:(void(^NS_NOESCAPE _Nonnull)(void))updates;

/*!
 * @discussion NSFilePresenter protocol conformance requirement.
 * @discussion Do not call this method manually, only call -forceUpdate.
 */
- (void)presentedItemDidChange;


@end

