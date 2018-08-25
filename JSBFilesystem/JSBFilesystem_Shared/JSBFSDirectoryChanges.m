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

@implementation JSBFSDirectoryChangesMove
-(instancetype)initWithFromValue:(NSInteger)fromValue toValue:(NSInteger)toValue;
{
    self = [super init];
    NSParameterAssert(self);
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
- (instancetype _Nullable)initWithIndexSetResult:(IGListIndexSetResult* _Nonnull)r;
{
    self = [super initWithIndexSetResult:r];
    if (!self) { return nil; }
    self->_updates = [r updates];
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
