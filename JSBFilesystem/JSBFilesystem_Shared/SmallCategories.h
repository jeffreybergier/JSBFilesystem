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

@interface NSArray (JSBFS)
/// Returns an immutable array if the original array is immutable
/// Returns a mutable array if the original array is mutable
- (NSArray*)JSBFS_arrayByTransformingArrayContentsWithBlock:(id _Nonnull (^_Nonnull)(id item))transform
NS_SWIFT_NAME(JSBFS_transformingArrayContents(withTransform:));
@end

@interface NSException (JSBFS)
+ (instancetype _Nonnull)JSBFS_initFailedException
NS_SWIFT_NAME(JSBFS_initFailedException());
@end

@interface NSObject (JSBFS)
- (instancetype _Nonnull)initThrowWhenNil;
@end

typedef NS_ENUM(NSInteger, JSBFSDirectorySort) {
    JSBFSDirectoryNameAFirst,
    JSBFSDirectoryNameZFirst,
    JSBFSDirectoryCreationNewestFirst,
    JSBFSDirectoryCreationOldestFirst,
    JSBFSDirectoryModificationNewestFirst,
    JSBFSDirectoryModificationOldestFirst
};

@interface JSBFSDirectorySortConverter: NSObject
+ (JSBFSDirectorySort)defaultSort;
+ (NSURLResourceKey)resourceKeyForSort:(JSBFSDirectorySort)sort;
+ (BOOL)orderedAscendingForSort:(JSBFSDirectorySort)sort;
@end
