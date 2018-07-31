//
//  SmallCategories.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 30/07/2018.
//

#import "SmallCategories.h"

@implementation NSArray (JSBFS)
- (NSArray*)JSBFS_arrayByTransformingArrayContentsWithBlock:(id _Nonnull (^_Nonnull)(id item))transform;
{
    NSMutableArray* transformed = [[NSMutableArray alloc] initWithCapacity:[self count]];
    for (id item in self) {
        [transformed addObject:transform(item)];
    }
    if ([self isKindOfClass:[NSMutableArray self]]) {
        return transformed;
    } else {
        return [transformed copy];
    }
}
@end

@implementation NSException (JSBFS)
+ (instancetype)JSBFS_initFailedException;
{
    return [[NSException alloc] initWithName:NSMallocException reason:@"INIT Failed" userInfo:nil];
}
@end

@implementation NSObject (JSBFS)
- (instancetype)initThrowWhenNil;
{
    if (self = [self init]) {
        return self;
    } else {
        @throw [NSException JSBFS_initFailedException];
    }
}
@end

@implementation JSBFSDirectorySortConverter
+ (JSBFSDirectorySort)defaultSort;
{
    return JSBFSDirectoryNameAFirst;
}
+ (NSURLResourceKey)resourceKeyForSort:(JSBFSDirectorySort)sort;
{
    switch (sort) {
        case JSBFSDirectoryNameAFirst:
        case JSBFSDirectoryNameZFirst:
            return NSURLLocalizedNameKey;

        case JSBFSDirectoryCreationNewestFirst:
        case JSBFSDirectoryCreationOldestFirst:
            return NSURLCreationDateKey;

        case JSBFSDirectoryModificationNewestFirst:
        case JSBFSDirectoryModificationOldestFirst:
            return NSURLContentModificationDateKey;
    }
}

/// This needs to be tested further
/// `testAscendingCreationDateSort` and related tests all pass
/// even when I switch the YES and the NO
+ (BOOL)orderedAscendingForSort:(JSBFSDirectorySort)sort;
{
    switch (sort) {
        case JSBFSDirectoryNameAFirst:
        case JSBFSDirectoryCreationOldestFirst:
        case JSBFSDirectoryModificationOldestFirst:
            return YES;
        case JSBFSDirectoryNameZFirst:
        case JSBFSDirectoryCreationNewestFirst:
        case JSBFSDirectoryModificationNewestFirst:
            return NO;
    }
}
@end
