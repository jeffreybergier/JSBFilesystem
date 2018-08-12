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
@import IGListKit;

@interface JSBFSObservedDirectory () <NSFilePresenter> {
    JSBFSObservedDirectoryChangeBlock _changesObserved;
}
@property (nonatomic, strong) NSArray<JSBFSFileComparison*>* _Nonnull internalState;
@property (readonly, nonatomic, strong) NSOperationQueue* _Nonnull queue;
@end

@implementation JSBFSObservedDirectory

@dynamic changesObserved;

// MARK: Init

- (instancetype _Nullable)initWithDirectoryURL:(NSURL* _Nonnull)url
                                createIfNeeded:(BOOL)create
                                      sortedBy:(JSBFSDirectorySort)sortedBy
                                    filteredBy:(NSArray<JSBFSDirectoryFilterBlock>* _Nullable)filters
                                    changeKind:(JSBFSObservedDirectyChangeKind)changeKind
                                         error:(NSError* _Nullable*)errorPtr;
{
    self = [self initWithDirectoryURL:url
                       createIfNeeded:create
                             sortedBy:sortedBy
                           filteredBy:filters
                                error:errorPtr];
    self->_changeKind = changeKind;
    return self;
}

- (instancetype _Nullable)initWithBase:(NSSearchPathDirectory)base
                appendingPathComponent:(NSString* _Nullable)pathComponent
                        createIfNeeded:(BOOL)create
                              sortedBy:(JSBFSDirectorySort)sortedBy
                            filteredBy:(NSArray<JSBFSDirectoryFilterBlock>* _Nullable)filters
                            changeKind:(JSBFSObservedDirectyChangeKind)changeKind
                                 error:(NSError*_Nullable*)errorPtr;
{
    self = [self initWithBase:base
       appendingPathComponent:pathComponent
               createIfNeeded:create
                     sortedBy:sortedBy
                   filteredBy:filters
                        error:errorPtr];
    self->_changeKind = changeKind;
    return self;
}

- (instancetype)initWithDirectoryURL:(NSURL*)url
                      createIfNeeded:(BOOL)create
                            sortedBy:(JSBFSDirectorySort)sortedBy
                          filteredBy:(NSArray<JSBFSDirectoryFilterBlock>* _Nullable)filters
                               error:(NSError**)errorPtr;
{
    NSError* error = nil;
    self = [super initWithDirectoryURL:url
                        createIfNeeded:create
                              sortedBy:sortedBy
                            filteredBy:filters
                                 error:errorPtr];
    if (error) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return nil;
    }

    self->_changeKind = JSBFSObservedDirectyChangeKindModificationsAsInsertionsDeletions;
    self->_changesObserved = nil;
    self->_internalState = [[NSArray alloc] init];
    self->_queue = [NSOperationQueue serialQueue];

    return self;
}

// MARK: Special Subclass API

- (void)forceUpdate;
{
    NSError* error = nil;
    NSArray<JSBFSFileComparison*>* lhs = [self internalState];
    NSArray<JSBFSFileComparison*>* rhs =
    [NSFileCoordinator JSBFS_urlComparisonsForFilesInDirectoryURL:[self url]
                                                         sortedBy:[self sortedBy]
                                                       filteredBy:[self filteredBy]
                                                            error:&error];
    if (error) { NSLog(@"%@", error); }
    JSBFSDirectoryChanges* changes = nil;
    switch ([self changeKind]) {
        case JSBFSObservedDirectyChangeKindModificationsAsInsertionsDeletions:
        {
            IGListIndexSetResult* result = [IGListDiff(lhs, rhs, IGListDiffEquality) resultForBatchUpdates];
            changes = [[JSBFSDirectoryChanges alloc] initWithIndexSetResult:result];
            break;
        }
        case JSBFSObservedDirectyChangeKindIncludingModifications:
        {
            IGListIndexSetResult* result = IGListDiff(lhs, rhs, IGListDiffEquality);
            changes = [[JSBFSDirectoryChangesFull alloc] initWithIndexSetResult:result];
            break;
        }
    }

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
            [NSFileCoordinator addFilePresenter:self];
            self->_changesObserved = changesObserved;
        } whileCoordinatingAccessAtURL:[self url] error:nil];
    } else {
        [NSFileCoordinator removeFilePresenter:self];
    }
}

- (JSBFSObservedDirectoryChangeBlock)changesObserved;
{
    return self->_changesObserved;
}

// MARK: NSFilePresenter Delegate

- (NSURL*)presentedItemURL;
{
    return [self url];
}

- (NSOperationQueue*)presentedItemOperationQueue;
{
    return [self queue];
}

- (void)presentedItemDidChange;
{
    [self forceUpdate];
}

// MARK: Basic API

- (NSInteger)contentsCount:(NSError*_Nullable*)errorPtr;
{
    __block NSError* error = nil;
    __block NSInteger count = -1;
    if ([self changesObserved] != NULL) {
        count = [[self internalState] count];
    } else {
        count = [super contentsCount:&error];
    }
    if (error || count == -1) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return 0;
    }
    return count;
}

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

- (NSInteger)indexOfItemWithURL:(NSURL* _Nonnull)rhs error:(NSError*_Nullable*)errorPtr;
{
    if ([self changesObserved] == NULL) {
        return [super indexOfItemWithURL:rhs error:errorPtr];
    }
    NSInteger index = NSNotFound;
    NSArray<JSBFSFileComparison*>* comparisons = [self sortedAndFilteredComparisons:errorPtr];
    index = [comparisons indexOfObjectPassingTest:
             ^BOOL(JSBFSFileComparison* lhs, NSUInteger idx, BOOL* stop) { return [[lhs fileURL] isEqual:rhs]; }];
    
    if (index == NSNotFound) {
        NSError* error = [[NSError alloc] initWithDomain:@"JSBFilesystem" code:1 userInfo:nil];
        if (errorPtr != NULL) { *errorPtr = error; }
        return NSNotFound;
    }
    return index;
}

// MARK: URL Api

- (NSURL* _Nullable)urlAtIndex:(NSInteger)index error:(NSError*_Nullable*)errorPtr;
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

// MARK: Data API - Read and Write Data

// MARK: File Wrapper API - Read and Write File Wrappers


@end
