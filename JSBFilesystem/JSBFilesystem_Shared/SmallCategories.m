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
#import "NSErrors.h"

@implementation NSArray (JSBFS)
- (NSArray*)JSBFS_arrayByTransformingArrayContentsWithBlock:(id _Nonnull (^_Nonnull)(id item))transform;
{
    NSParameterAssert(transform);
    NSMutableArray* transformed = [[NSMutableArray alloc] initWithCapacity:[self count]];
    for (id item in self) {
        [transformed addObject:transform(item)];
    }
    if ([self count] != [transformed count]) {
        @throw [NSException JSBFS_arrayMapFailedInputCountDoesNotMatchOutputCount];
    }
    if ([self isKindOfClass:[NSMutableArray self]]) {
        return transformed;
    } else {
        return [transformed copy];
    }
}
- (NSArray*)JSBFS_arrayByFilteringArrayContentsWithBlock:(BOOL (^_Nonnull)(id item))isIncludedBlock;
{
    NSParameterAssert(isIncludedBlock);
    NSMutableArray* filtered = [[NSMutableArray alloc] initWithCapacity:[self count]];
    for (id item in self) {
        BOOL isIncluded = isIncludedBlock(item);
        if (isIncluded) {
            [filtered addObject:item];
        }
    }
    if ([self isKindOfClass:[NSMutableArray self]]) {
        return filtered;
    } else {
        return [filtered copy];
    }
}
@end

@implementation NSOperationQueue (JSBFS)
+ (instancetype)JSBFS_serialQueue;
{
    NSOperationQueue* q = [[NSOperationQueue alloc] init];
    [q setQualityOfService:NSQualityOfServiceUserInitiated];
    NSString* qLabel = [NSString stringWithFormat:@"com.saturdayapps.JSBFSObserver.%p", (void*)q];
    [q setUnderlyingQueue:dispatch_queue_create([qLabel UTF8String], DISPATCH_QUEUE_SERIAL)];
    [q setMaxConcurrentOperationCount:1];
    return q;
}
@end
