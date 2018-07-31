//
//  JSBFSDirectoryObserver.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 28/07/2018.
//

#import "JSBFSDirectoryObserver.h"
#import "NSFileCoordinator+JSBFS.h"
#import "JSBFSFileComparison.h"
@import IGListKit;

@interface JSBFSDirectoryObserver () <NSFilePresenter> {
    JSBFSDirectoryObserverChangeBlock _changesObserved;
}

@property (readonly, nonatomic, strong) NSOperationQueue* _Nonnull operationQueue;
@property (nonatomic, strong) NSArray<JSBFSFileComparison*>* _Nonnull internalState;

@end

@implementation JSBFSDirectoryObserver

@dynamic contentsCount;
@dynamic changesObserved;

- (instancetype _Nonnull)initWithDirectoryURL:(NSURL*)url
                          sortedByResourceKey:(NSURLResourceKey)resourceKey
                             orderedAscending:(BOOL)ascending;
{
    if (self = [super init]) {
        _orderedAscending = ascending;
        _sortedBy = resourceKey;
        _observedDirectoryURL = url;
        _changesObserved = nil;
        _internalState = [[NSArray alloc] init];

        NSOperationQueue* q = [[NSOperationQueue alloc] init];
        q.qualityOfService = NSQualityOfServiceUserInitiated;
        _operationQueue = q;
        return self;
    } else {
        @throw [[NSException alloc] initWithName:NSMallocException reason:@"INIT Failed" userInfo:nil];
    }
}

- (void)forceUpdate;
{
    NSArray<JSBFSFileComparison*>* lhs = [self internalState];
    NSArray<JSBFSFileComparison*>* rhs = [NSFileCoordinator JSBFS_urlComparisonsForFilesInDirectoryURL:[self observedDirectoryURL]
                                                                                   sortedByResourceKey:[self sortedBy]
                                                                                      orderedAscending:[self orderedAscending]
                                                                                                 error:nil];
    IGListIndexSetResult* result = [IGListDiff(lhs, rhs, IGListDiffEquality) resultForBatchUpdates];
    JSBFSDirectoryChanges* changes = [[JSBFSDirectoryChanges alloc] initWithIndexSetResult:result];

    [self setInternalState:rhs];
    JSBFSDirectoryObserverChangeBlock block = [self changesObserved];
    if (changes && block != NULL) {
        block(changes);
    }
}

- (void)setChangesObserved:(JSBFSDirectoryObserverChangeBlock)changesObserved;
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
        } whileCoordinatingAccessAtURL:[self observedDirectoryURL] error:nil];
    } else {
        [NSFileCoordinator removeFilePresenter:self];
    }
}

- (JSBFSDirectoryObserverChangeBlock)changesObserved;
{
    return self->_changesObserved;
}

- (NSInteger)contentsCount;
{
    NSArray* state = [self internalState];
    if (state) {
        return [state count];
    } else {
        return 0;
    }
}

- (NSURL *)urlAtIndex:(NSInteger)index
{
    return [[[self internalState] objectAtIndex:index] fileURL];
}

- (NSData*)dataAtIndex:(NSInteger)index error:(NSError**)errorPtr;
{
    NSURL* url = [self urlAtIndex:index];
    return [NSFileCoordinator JSBFS_readDataFromURL:url error:errorPtr];
}

- (NSURL*)presentedItemURL;
{
    return [self observedDirectoryURL];
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
