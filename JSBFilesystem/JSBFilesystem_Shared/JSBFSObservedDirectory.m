//
//  JSBFSDirectoryObserver.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 28/07/2018.
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
                                              sortedByResourceKey:[JSBFSDirectorySortConverter resourceKeyForSort:[self sortedBy]]
                                                 orderedAscending:[JSBFSDirectorySortConverter orderedAscendingForSort:[self sortedBy]]
                                                            error:&error];
    if (error) { NSLog(@"%@", error); }
    IGListIndexSetResult* result = [IGListDiff(lhs, rhs, IGListDiffEquality) resultForBatchUpdates];
    JSBFSDirectoryChanges* changes = [[JSBFSDirectoryChanges alloc] initWithIndexSetResult:result];

    [self setInternalState:rhs];
    JSBFSObservedDirectoryChangeBlock block = [self changesObserved];
    if (changes && block != NULL) {
        block(changes);
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
