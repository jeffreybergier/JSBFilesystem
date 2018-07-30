//
//  JSBFSDirectoryObserver_Testable.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 30/07/2018.
//

#import "JSBFSDirectoryObserver_Testable.h"

@interface JSBFSDirectoryObserver_Testable () {
    NSArray<JSBFSFileComparison*>* _internalState;
}

@end

@implementation JSBFSDirectoryObserver_Testable

- (void)forceUpdate;
{
    NSArray<JSBFSFileComparison*>* lhs = _internalState;
    NSArray<JSBFSFileComparison*>* rhs = [NSFileCoordinator JSBFS_urlComparisonsForFilesInDirectoryURL:[self observedDirectoryURL]
                                                                                   sortedByResourceKey:[self sortedBy]
                                                                                      orderedAscending:[self orderedAscending]
                                                                                                 error:nil];
    IGListIndexSetResult* result = IGListDiff(lhs, rhs, 0);
    JSBFSDirectoryChanges_Testable* changes = [[JSBFSDirectoryChanges_Testable alloc] initWithIndexSetResult:result];

    _internalState = rhs;
    JSBFSDirectoryObserverChangeBlock block = [self changesObserved];
    if (changes && block != NULL) {
        block(changes);
    }
}

@end

@implementation JSBFSDirectoryChanges_Testable
- (instancetype _Nullable)initWithIndexSetResult:(IGListIndexSetResult* _Nonnull)r;
{
    self = [super initWithIndexSetResult:r];
    _updates = [r updates];
    return self;
}
@end
