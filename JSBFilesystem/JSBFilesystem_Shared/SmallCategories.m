//
//  SmallCategories.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 30/07/2018.
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
