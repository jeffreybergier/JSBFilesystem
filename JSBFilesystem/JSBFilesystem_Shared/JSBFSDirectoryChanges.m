//
//  JSBFSDirectoryChanges.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 28/07/2018.
//

#import "JSBFSDirectoryChanges.h"
#import "SmallCategories.h"

@implementation JSBFSDirectoryChangesMove
-(instancetype)initWithFromValue:(NSInteger)fromValue toValue:(NSInteger)toValue;
{
    if (self = [super init]) {
        _from = fromValue;
        _to = toValue;
        return self;
    } else {
        @throw [[NSException alloc] initWithName:NSMallocException reason:@"INIT Failed" userInfo:nil];
    }
}
@end

@implementation JSBFSDirectoryChanges

-(instancetype)initWithInsertions:(NSIndexSet*)insertions
                                 deletions:(NSIndexSet*)deletions
                                     moves:(NSArray<JSBFSDirectoryChangesMove*>*)moves;
{
    if (self = [super init]) {
        _insertions = insertions;
        _deletions = deletions;
        _moves = moves;
        return self;
    } else {
        @throw [[NSException alloc] initWithName:NSMallocException reason:@"INIT Failed" userInfo:nil];
    }
}

@end

@implementation JSBFSDirectoryChanges (IGListKit)
- (instancetype _Nullable)initWithIndexSetResult:(IGListIndexSetResult* _Nonnull)r;
{
    if (![r hasChanges]) { return nil; }
    NSArray<JSBFSDirectoryChangesMove *>* moves = [[r moves] JSBFS_arrayByTransformingArrayContentsWithBlock:^id _Nonnull(IGListMoveIndex* item)
    {
        return [[JSBFSDirectoryChangesMove alloc] initWithFromValue:[item from] toValue:[item to]];
    }];
    return [self initWithInsertions:[r inserts] deletions:[r deletes] moves:moves];
}
@end
