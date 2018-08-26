//
//  SmallCategories.h
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

@import Foundation;

typedef BOOL(^JSBFSDirectoryFilterBlock)(NSURL* _Nonnull aURL);

@interface NSArray (JSBFS)
/// Returns an immutable array if the original array is immutable
/// Returns a mutable array if the original array is mutable
- (NSArray*)JSBFS_arrayByTransformingArrayContentsWithBlock:(id _Nonnull (^_Nonnull)(id item))transform
NS_SWIFT_NAME(JSBFS_transformingArrayContents(withTransform:));
/// Returns an immutable array if the original array is immutable
/// Returns a mutable array if the original array is mutable
- (NSArray*)JSBFS_arrayByFilteringArrayContentsWithBlock:(BOOL (^_Nonnull)(id item))isIncluded
NS_SWIFT_NAME(JSBFS_filteringArrayContents(_:));
@end

typedef NS_ENUM(NSInteger, JSBFSDirectorySort) {
    JSBFSDirectorySortNameAFirst,
    JSBFSDirectorySortNameZFirst,
    JSBFSDirectorySortCreationNewestFirst,
    JSBFSDirectorySortCreationOldestFirst,
    JSBFSDirectorySortModificationNewestFirst,
    JSBFSDirectorySortModificationOldestFirst
};

@interface JSBFSDirectorySortConverter: NSObject
@property (class, nonatomic, readonly) JSBFSDirectorySort defaultSort;
+ (NSURLResourceKey)resourceKeyForSort:(JSBFSDirectorySort)sort;
+ (BOOL)orderedAscendingForSort:(JSBFSDirectorySort)sort;
@end

@interface NSOperationQueue (JSBFS)
+ (instancetype _Nonnull)JSBFS_serialQueue;
@end

@interface JSBFSDoubleBool: NSObject
@property (readonly, nonatomic) BOOL value1;
@property (readonly, nonatomic) BOOL value2;
- (instancetype)initWithValue1:(BOOL)value1 value2:(BOOL)value2;
@end
