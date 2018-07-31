//
//  JSBFSDirectoryObserver_Testable.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 30/07/2018.
//

#import "JSBFSObservedDirectory_Testable.h"

@interface JSBFSObservedDirectory_Testable () {
    NSArray<JSBFSFileComparison*>* _internalState;
}

@end

@implementation JSBFSObservedDirectory_Testable

- (void)forceUpdate;
{
    NSArray<JSBFSFileComparison*>* lhs = _internalState;
    NSArray<JSBFSFileComparison*>* rhs =
    [NSFileCoordinator JSBFS_urlComparisonsForFilesInDirectoryURL:[self url]
                                              sortedByResourceKey:[JSBFSDirectorySortConverter resourceKeyForSort:[self sortedBy]]
                                                 orderedAscending:[JSBFSDirectorySortConverter orderedAscendingForSort:[self sortedBy]]
                                                            error:nil];
    IGListIndexSetResult* result = IGListDiff(lhs, rhs, IGListDiffEquality);
    JSBFSDirectoryChanges_Testable* changes = [[JSBFSDirectoryChanges_Testable alloc] initWithIndexSetResult:result];

    _internalState = rhs;
    JSBFSObservedDirectoryChangeBlock block = [self changesObserved];
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
