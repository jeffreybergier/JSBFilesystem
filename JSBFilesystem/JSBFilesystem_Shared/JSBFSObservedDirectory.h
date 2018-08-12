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

typedef NS_ENUM(NSInteger, JSBFSObservedDirectyChangeKind) {
    JSBFSObservedDirectyChangeKindIncludingModifications,
    JSBFSObservedDirectyChangeKindModificationsAsInsertionsDeletions,
};

typedef void(^JSBFSObservedDirectoryChangeBlock)(JSBFSDirectoryChanges* _Nonnull changes);

@interface JSBFSObservedDirectory: JSBFSDirectory

/// Registers intent to be updated to filesystem changes
/// NSFilePresenters are strongly held by the system
/// You must set this to NIL when done with this object or else memory will leak
/// When this is set, the internal state is forcefully updated
/// So that subsequent changes can be correctly found
/// This always calls back on the main queue. Its intended for UI use
@property (nonatomic, strong) JSBFSObservedDirectoryChangeBlock _Nullable changesObserved;
@property (readonly, nonatomic) NSInteger contentsCount;
/// Default is 0.2 seconds
@property (nonatomic) NSTimeInterval updateDelay;
/// 
/// Some collections support reloading data in a batch update and some do not
/// `UICollectionView` does not support this but `UITableView` and `NSOutlineView` do
/// When set to `JSBFSObservedDirectyChangeKindModificationsAsInsertionsDeletions`
/// the `UICollectionView` behavior is performed. The `changesObserved` block will be
/// called with a `JSBFSDirectoryChanges` object.
/// When set to `JSBFSObservedDirectyChangeKindIncludingModifications`
/// the more sophisticated behavior will be used. This will cause the `changesObserved`
/// block to be called with a `JSBFSDirectoryChangesFull` object which contains the updates
/// Make sure to cast it appropriately in your block.
///
@property (nonatomic) JSBFSObservedDirectyChangeKind changeKind;
- (instancetype _Nullable)initWithDirectoryURL:(NSURL* _Nonnull)url
                      createIfNeeded:(BOOL)create
                            sortedBy:(JSBFSDirectorySort)sortedBy
                          filteredBy:(NSArray<JSBFSDirectoryFilterBlock>* _Nullable)filters
                          changeKind:(JSBFSObservedDirectyChangeKind)changeKind
                               error:(NSError* _Nullable*)errorPtr;
- (instancetype _Nullable)initWithBase:(NSSearchPathDirectory)base
                appendingPathComponent:(NSString* _Nullable)pathComponent
                        createIfNeeded:(BOOL)create
                              sortedBy:(JSBFSDirectorySort)sortedBy
                            filteredBy:(NSArray<JSBFSDirectoryFilterBlock>* _Nullable)filters
                            changeKind:(JSBFSObservedDirectyChangeKind)changeKind
                                 error:(NSError*_Nullable*)errorPtr;
- (void)forceUpdate;
- (void)performBatchUpdates:(void(^NS_NOESCAPE _Nonnull)(void))updates;
@end

