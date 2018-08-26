//
//  JSBFSDirectoryChanges.m
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

#import "JSBFSDirectoryChanges.h"
#import "SmallCategories.h"
#import "JSBFSObservedDirectory.h"

@implementation JSBFSDirectoryChanges

@synthesize insertions = _insertions, deletions = _deletions, moves = _moves;

-(instancetype _Nonnull)initWithInsertions:(NSIndexSet*_Nonnull)insertions
                                 deletions:(NSIndexSet*_Nonnull)deletions
                                     moves:(NSArray<JSBFSDirectoryChangesMove*>*_Nonnull)moves;
{
    NSParameterAssert(insertions);
    NSParameterAssert(deletions);
    NSParameterAssert(moves);
    self = [super init];
    NSParameterAssert(self);
    self->_insertions = insertions;
    self->_deletions = deletions;
    self->_moves = moves;
    return self;
}
- (NSString *)description;
{
    NSString* og = [super description];
    return [NSString stringWithFormat:@"%@ Insertions: %lu, Deletions: %lu, Moves: %lu",
            og, (unsigned long)[[self insertions] count], (unsigned long)[[self deletions] count], (unsigned long)[[self moves] count]];
}

@end

@implementation JSBFSDirectoryChangesFull
@synthesize updates = _updates;
-(instancetype _Nonnull)initWithInsertions:(NSIndexSet*_Nonnull)insertions
                                 deletions:(NSIndexSet*_Nonnull)deletions
                                     moves:(NSArray<JSBFSDirectoryChangesMove*>*_Nonnull)moves
                                   updates:(NSIndexSet*_Nonnull)updates;
{
    NSParameterAssert(insertions);
    NSParameterAssert(deletions);
    NSParameterAssert(moves);
    NSParameterAssert(updates);
    self = [super initWithInsertions:insertions deletions:deletions moves:moves];
    NSParameterAssert(self);
    self->_updates = updates;
    return self;
}

- (NSString *)description;
{
    NSString* og = [super description];
    return [NSString stringWithFormat:@"%@, Updates: %lu",
            og, (unsigned long)[[self updates] count]];
}

@end

@implementation JSBFSDirectoryChangesMove
@synthesize from = _from, to = _to;
-(instancetype)initWithFromValue:(NSInteger)fromValue toValue:(NSInteger)toValue;
{
    self = [super init];
    NSParameterAssert(self);
    self->_from = fromValue;
    self->_to = toValue;
    return self;
}
@end

@implementation IGListIndexSetResult (JSBFS)
- (JSBFSDirectoryChanges*_Nullable)changeObjectForChangeKind:(JSBFSObservedDirectoryChangeKind)changeKind;
{
    // convert to the right type object based on our change kind
    IGListIndexSetResult* newSelf = nil;
    switch (changeKind) {
        case JSBFSObservedDirectoryChangeKindIncludingModifications:
            newSelf = self;
            break;
        case JSBFSObservedDirectoryChangeKindModificationsAsInsertionsDeletions:
            newSelf = [self resultForBatchUpdates];
            break;
    }
    // make sure we have an object we're dealing with after conversion
    NSParameterAssert(newSelf);
    // if there are no changes, return NIL
    if (![self hasChanges]) { return nil; }
    // convert from IGListKit moves to my own Moves
    NSArray<JSBFSDirectoryChangesMove *>* moves =
    [[self moves] JSBFS_arrayByTransformingArrayContentsWithBlock: ^id _Nonnull(IGListMoveIndex* item)
     {
         return [[JSBFSDirectoryChangesMove alloc] initWithFromValue:[item from] toValue:[item to]];
     }];
    // now construct the right kind of object based on the changeKind
    switch (changeKind) {
        case JSBFSObservedDirectoryChangeKindIncludingModifications:
            return [[JSBFSDirectoryChangesFull alloc] initWithInsertions:[self inserts]
                                                               deletions:[self deletes]
                                                                   moves:moves
                                                                 updates:[self updates]];
        case JSBFSObservedDirectoryChangeKindModificationsAsInsertionsDeletions:
            return [[JSBFSDirectoryChanges alloc] initWithInsertions:[newSelf inserts]
                                                           deletions:[newSelf deletes]
                                                               moves:moves];
    }
}
@end
