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
    self = [super initThrowWhenNil];
    self->_from = fromValue;
    self->_to = toValue;
    return self;
}
@end

@implementation JSBFSDirectoryChanges

-(instancetype)initWithInsertions:(NSIndexSet*)insertions
                                 deletions:(NSIndexSet*)deletions
                                     moves:(NSArray<JSBFSDirectoryChangesMove*>*)moves;
{
    self = [super initThrowWhenNil];
    self->_insertions = insertions;
    self->_deletions = deletions;
    self->_moves = moves;
    return self;
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
