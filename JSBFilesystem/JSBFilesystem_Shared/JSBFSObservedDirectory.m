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
#import "JSBFSFileComparison.h"
#import "SmallCategories.h"
#import "JSBFSDirectoryChanges.h"
@import IGListKit;

@interface JSBFSObservedDirectory () {
    JSBFSObservedDirectoryChangeBlock _changesObserved;
}
@property (nonatomic, strong) NSArray<JSBFSFileComparison*>* _Nonnull internalState;
@property (nonatomic, strong) NSTimer* _Nullable updateWaitTimer;
@end

@implementation JSBFSObservedDirectory

@synthesize changeKind = _changeKind, updateDelay = _updateDelay, presentedItemOperationQueue = _presentedItemOperationQueue;
@synthesize internalState = _internalState, updateWaitTimer = _updateWaitTimer;
@dynamic changesObserved, presentedItemURL;

// MARK: Init

- (instancetype _Nullable)initWithDirectoryURL:(NSURL* _Nonnull)url
                                createIfNeeded:(BOOL)create
                                      sortedBy:(JSBFSDirectorySort)sortedBy
                                    filteredBy:(NSArray<JSBFSDirectoryFilterBlock>* _Nullable)filters
                                    changeKind:(JSBFSObservedDirectoryChangeKind)changeKind
                                         error:(NSError* _Nullable*)errorPtr;
{
    self = [super initWithDirectoryURL:url
                        createIfNeeded:create
                              sortedBy:sortedBy
                            filteredBy:filters
                                 error:errorPtr];
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
    self = [super initWithBase:base
        appendingPathComponent:pathComponent
                createIfNeeded:create
                      sortedBy:sortedBy
                    filteredBy:filters
                         error:errorPtr];
    self->_changeKind = changeKind;
    self->_changesObserved = nil;
    self->_updateDelay = 0.2;
    self->_internalState = [[NSArray alloc] init];
    self->_presentedItemOperationQueue = [NSOperationQueue JSBFS_serialQueue];
    return self;
}

// MARK: Special Subclass API

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
    if (error) { NSLog(@"%@", error); }
    IGListIndexSetResult* result = IGListDiff(lhs, rhs, IGListDiffEquality);
    JSBFSDirectoryChanges* changes = [result changeObjectForChangeKind:[self changeKind]];
    [self setInternalState:rhs];
    JSBFSObservedDirectoryChangeBlock block = [self changesObserved];
    if (changes && block != NULL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(changes);
        });
    }
}

- (void)setChangesObserved:(JSBFSObservedDirectoryChangeBlock)changesObserved;
{
    // clear out the internal state and block
    self->_changesObserved = nil;
    [self setInternalState:[[NSArray alloc] init]];

    // if we were passed a new block
    // We need to do things in sync with the FileCoordinator
    if (changesObserved != NULL) {
        [NSFileCoordinator JSBFS_executeBlock:^{
            [self forceUpdate];
            self->_changesObserved = changesObserved;
            [NSFileCoordinator addFilePresenter:self];
        } whileCoordinatingAccessAtURL:[self url] error:nil];
    } else {
        [NSFileCoordinator removeFilePresenter:self];
    }
}

- (JSBFSObservedDirectoryChangeBlock)changesObserved;
{
    return self->_changesObserved;
}

- (void)performBatchUpdates:(void(^NS_NOESCAPE _Nonnull)(void))updates;
{
    [NSFileCoordinator removeFilePresenter:self];
    updates();
    [self forceUpdate];
    if ([self changesObserved] != NULL) {
        // only add the file presenter back if we're supposed to be observing
        [NSFileCoordinator addFilePresenter:self];
    }
}

// MARK: NSFilePresenter Delegate

- (NSURL*)presentedItemURL;
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

// MARK: OVERRIDE -urlAtIndex:error:

- (NSURL* _Nullable)urlAtIndex:(NSUInteger)index error:(NSError*_Nullable*)errorPtr;
{
    __block NSError* error = nil;
    __block NSURL* url = nil;
    if ([self changesObserved] != NULL) {
        url = [[[self sortedAndFilteredComparisons:&error] objectAtIndex:index] fileURL];
    } else {
        url = [super urlAtIndex:index error:&error];
    }
    if (error || !url) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return nil;
    }
    return url;
}

// MARK: OVERRIDE -contentsCount:

- (NSUInteger)contentsCount:(NSError*_Nullable*)errorPtr;
{
    __block NSError* error = nil;
    __block NSUInteger count = NSNotFound;
    if ([self changesObserved] != NULL) {
        count = [[self internalState] count];
    } else {
        count = [super contentsCount:&error];
    }
    if (error || count == NSNotFound) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return 0;
    }
    return count;
}

// MARK: OVERRIDE -sortedAndFiltered:

- (NSArray<NSURL*>* _Nullable)sortedAndFilteredContents:(NSError*_Nullable*)errorPtr;
{
    if ([self changesObserved] == NULL) {
        return [super sortedAndFilteredContents:errorPtr];
    }
    NSArray<JSBFSFileComparison*>* comparisons = [self sortedAndFilteredComparisons:errorPtr];
    NSArray<NSURL*>* urls = [comparisons JSBFS_arrayByTransformingArrayContentsWithBlock:
                             ^id _Nonnull(JSBFSFileComparison* item)
                             {
                                 return [item fileURL];
                             }];
    return urls;
}

- (NSArray<JSBFSFileComparison*>* _Nonnull)sortedAndFilteredComparisons:(NSError*_Nullable*)errorPtr;
{
    if ([self changesObserved] == NULL) {
        return [super sortedAndFilteredComparisons:errorPtr];
    }
    return [self internalState];
}

- (void)dealloc;
{
    self->_changesObserved = nil;
    [self->_updateWaitTimer invalidate];
}

@end
