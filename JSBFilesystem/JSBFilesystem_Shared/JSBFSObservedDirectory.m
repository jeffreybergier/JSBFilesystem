//
//  JSBFSDirectoryObserver.m
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

#import "JSBFSObservedDirectory.h"
#import "NSFileCoordinator+JSBFS.h"
#import "NSFileCoordinator+Internal.h"
#import "JSBFSDirectory+Internal.h"
#import "JSBFSDirectoryChanges.h"
#import "JSBFSFileComparison.h"
#import "SmallCategories.h"
#import "NSErrors.h"
@import IGListKit;

@interface JSBFSObservedDirectory () {
    JSBFSObservedDirectoryChangeBlock _changesObserved;
}
@property (nonatomic, strong) NSArray<JSBFSFileComparison*>* _Nonnull internalState;
@property (nonatomic, strong) NSTimer* _Nullable updateWaitTimer;
@end

@implementation JSBFSObservedDirectory

@synthesize changeKind = _changeKind, updateDelay = _updateDelay,
                        presentedItemOperationQueue = _presentedItemOperationQueue,
                        internalState = _internalState, updateWaitTimer = _updateWaitTimer,
                        changesObserved = _changesObserved;
@dynamic presentedItemURL;

// MARK: Init

- (instancetype _Nullable)initWithDirectoryURL:(NSURL* _Nonnull)url
                                createIfNeeded:(BOOL)create
                                      sortedBy:(JSBFSDirectorySort)sortedBy
                                    filteredBy:(NSArray<JSBFSDirectoryFilterBlock>* _Nullable)filters
                                    changeKind:(JSBFSObservedDirectoryChangeKind)changeKind
                                         error:(NSError* _Nullable*)errorPtr;
{
    NSParameterAssert(changeKind >= JSBFSObservedDirectoryChangeKindIncludingModifications);
    NSParameterAssert(changeKind <= JSBFSObservedDirectoryChangeKindModificationsAsInsertionsDeletions);
    self = [super initWithDirectoryURL:url
                        createIfNeeded:create
                              sortedBy:sortedBy
                            filteredBy:filters
                                 error:errorPtr];
    if (!self) { return nil; }
    self->_changeKind = changeKind;
    self->_changesObserved = nil;
    self->_updateDelay = 0.2;
    self->_internalState = [[NSArray alloc] init];
    self->_presentedItemOperationQueue = [NSOperationQueue JSBFS_serialQueue];
    return self;
}

- (instancetype _Nullable)initWithBase:(NSSearchPathDirectory)base
                appendingPathComponent:(NSString* _Nullable)pathComponent
                        createIfNeeded:(BOOL)create
                              sortedBy:(JSBFSDirectorySort)sortedBy
                            filteredBy:(NSArray<JSBFSDirectoryFilterBlock>* _Nullable)filters
                            changeKind:(JSBFSObservedDirectoryChangeKind)changeKind
                                 error:(NSError*_Nullable*)errorPtr;
{
    NSParameterAssert(changeKind >= JSBFSObservedDirectoryChangeKindIncludingModifications);
    NSParameterAssert(changeKind <= JSBFSObservedDirectoryChangeKindModificationsAsInsertionsDeletions);
    self = [super initWithBase:base
        appendingPathComponent:pathComponent
                createIfNeeded:create
                      sortedBy:sortedBy
                    filteredBy:filters
                         error:errorPtr];
    if (!self) { return nil; }
    self->_changeKind = changeKind;
    self->_changesObserved = nil;
    self->_updateDelay = 0.2;
    self->_internalState = [[NSArray alloc] init];
    self->_presentedItemOperationQueue = [NSOperationQueue JSBFS_serialQueue];
    return self;
}

// MARK: Special Subclass API

- (void)setFilteredBy:(NSArray<JSBFSDirectoryFilterBlock> *)filteredBy;
{
    [super setFilteredBy:filteredBy];
    [self forceUpdate];
}

- (void)setSortedBy:(JSBFSDirectorySort)sortedBy;
{
    [super setSortedBy:sortedBy];
    [self forceUpdate];
}

- (void)setChangesObserved:(JSBFSObservedDirectoryChangeBlock)changesObserved;
{
    self->_changesObserved = nil;
    [self setInternalState:[[NSArray alloc] init]];
    [NSFileCoordinator removeFilePresenter:self];

    if (!changesObserved) { return; }
    [self forceUpdate];
    self->_changesObserved = changesObserved;
    [NSFileCoordinator addFilePresenter:self];
}

- (void)forceUpdate;
{
    NSError* error = nil;
    NSArray<JSBFSFileComparison*>* lhs = [self internalState];
    NSArray<JSBFSFileComparison*>* rhs =
    [NSFileCoordinator JSBFS_comparableContentsOfDirectoryAtURL:[self url]
                                                       sortedBy:[self sortedBy]
                                                     filteredBy:[self filteredBy]
                                                  filePresenter:nil
                                                          error:&error];
    if (error) {
        NSLog(@"%@", error);
        rhs = [[NSArray alloc] init];
    }
    IGListIndexSetResult* result = IGListDiff(lhs, rhs, IGListDiffEquality);
    JSBFSDirectoryChanges* changes = [result changeObjectForChangeKind:[self changeKind]];
    JSBFSObservedDirectoryChangeBlock block = [self changesObserved];
    [self setInternalState:rhs];
    if (changes && block) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(changes);
        });
    }
}

- (void)performBatchUpdates:(void(^NS_NOESCAPE _Nonnull)(void))updates;
{
    NSParameterAssert(updates);
    [NSFileCoordinator removeFilePresenter:self];
    updates();
    [self forceUpdate];
    if ([self changesObserved]) {
        [NSFileCoordinator addFilePresenter:self];
    }
}

// MARK: NSFilePresenter Delegate

- (NSURL *)presentedItemURL;
{
    return [self url];
}

- (void)presentedItemDidChange;
{
    [[self updateWaitTimer] invalidate];
    id __weak welf = self;
    NSTimer* newTimer = [NSTimer timerWithTimeInterval:[self updateDelay] repeats:NO block:^(NSTimer * _Nonnull timer) {
        // silence the objective c welf warning
        id __strong strong_welf = welf;
        if (!strong_welf) { return; }
        // make sure this timer doesn't repeat
        [timer invalidate];
        [[strong_welf updateWaitTimer] invalidate];
        [strong_welf setUpdateWaitTimer:nil];
        // hop back onto the serial queue and force an update
        NSOperationQueue* queue = [strong_welf presentedItemOperationQueue];
        if (!queue) { return; }
        dispatch_async([queue underlyingQueue], ^{
            [strong_welf forceUpdate];
        });
    }];
    [self setUpdateWaitTimer:newTimer];
    // NSTimer only appears to work on the main thread
    [[NSRunLoop mainRunLoop] addTimer:[self updateWaitTimer] forMode:NSDefaultRunLoopMode];
}

// MARK: OVERRIDE -sortedAndFiltered:

- (NSArray<NSURL*>* _Nullable)contentsSortedAndFiltered:(NSError*_Nullable*)errorPtr;
{
    if (![self changesObserved]) {
        return [super contentsSortedAndFiltered:errorPtr];
    }
    NSArray<JSBFSFileComparison*>* comparisons = [self internalState];
    NSArray<NSURL*>* urls = [comparisons JSBFS_arrayByTransformingArrayContentsWithBlock:
                             ^id _Nonnull(JSBFSFileComparison* item)
                             {
                                 return [item fileURL];
                             }];
    return urls;
}

- (NSArray<JSBFSFileComparison*>* _Nonnull)comparableContentsSortedAndFiltered:(NSError*_Nullable*)errorPtr;
{
    if (![self changesObserved]) {
        return [super comparableContentsSortedAndFiltered:errorPtr];
    }
    return [self internalState];
}

- (void)dealloc;
{
    [self->_updateWaitTimer invalidate];
}

@end
