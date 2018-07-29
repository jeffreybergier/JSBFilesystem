//
//  JSBFSDirectoryChanges.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 28/07/2018.
//

#import "JSBFSDirectoryChanges.h"

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
