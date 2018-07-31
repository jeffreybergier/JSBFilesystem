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

@property (readonly, nonatomic, strong) NSOperationQueue* _Nonnull operationQueue;
@property (nonatomic, strong) NSArray<JSBFSFileComparison*>* _Nonnull internalState;

@end

@implementation JSBFSObservedDirectory

@dynamic changesObserved;

- (instancetype)initWithDirectoryURL:(NSURL*)url
                      createIfNeeded:(BOOL)create
                            sortedBy:(JSBFSDirectorySort)sortedBy
                               error:(NSError**)errorPtr;
{
    NSError* error = nil;
    self = [super initWithDirectoryURL:url
                        createIfNeeded:create
                              sortedBy:sortedBy
                                 error:errorPtr];
    if (error) {
        *errorPtr = error;
        return nil;
    }
    self->_changesObserved = nil;
    self->_internalState = [[NSArray alloc] init];
    NSOperationQueue* q = [[NSOperationQueue alloc] init];
    q.qualityOfService = NSQualityOfServiceUserInitiated;
    self->_operationQueue = q;

    return self;
}

- (void)forceUpdate;
{
    NSError* error = nil;
    NSArray<JSBFSFileComparison*>* lhs = [self internalState];
    NSArray<JSBFSFileComparison*>* rhs =
    [NSFileCoordinator JSBFS_urlComparisonsForFilesInDirectoryURL:[self url]
                                                         sortedBy:[self sortedBy]
                                                            error:&error];
    if (error) { NSLog(@"%@", error); }
    IGListIndexSetResult* result = [IGListDiff(lhs, rhs, IGListDiffEquality) resultForBatchUpdates];
    JSBFSDirectoryChanges* changes = [[JSBFSDirectoryChanges alloc] initWithIndexSetResult:result];

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

- (NSInteger)contentsCount:(NSError** _Nullable)errorPtr;
{
    NSArray* state = [self internalState];
    if (state) {
        return [state count];
    } else {
        return 0;
    }
}

- (NSURL*)urlAtIndex:(NSInteger)index error:(NSError**)errorPtr;
{
    return [[[self internalState] objectAtIndex:index] fileURL];
}

- (NSData*)dataAtIndex:(NSInteger)index error:(NSError**)errorPtr;
{
    NSURL* url = [self urlAtIndex:index error:nil];
    return [NSFileCoordinator JSBFS_readDataFromURL:url error:errorPtr];
}

- (NSURL*)presentedItemURL;
{
    return [self url];
}

- (NSOperationQueue*)presentedItemOperationQueue;
{
    return [self operationQueue];
}

- (void)presentedItemDidChange;
{
    [self forceUpdate];
}

@end
