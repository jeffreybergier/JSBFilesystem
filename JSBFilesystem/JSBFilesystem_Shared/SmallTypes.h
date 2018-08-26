//
//  SmallTypes.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/26/18.
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
@class JSBFSDirectoryChanges;
typedef NS_ENUM(NSInteger, JSBFSDirectorySort);

/*!
 * @discussion Because Objective-C does not support tuples, this object is intended
 *             to represent a 2 value tuple where each value is of type BOOL.
 * @discussion This object preserves value semantics.
 */
@interface JSBFSDoubleBool: NSObject
@property (readonly, nonatomic) BOOL value1;
@property (readonly, nonatomic) BOOL value2;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithValue1:(BOOL)value1 value2:(BOOL)value2
NS_DESIGNATED_INITIALIZER;
@end

/*!
 * @discussion Because Objective-C does not support categories on ENUM types
 *             this class is intended to store default values and convert
 *             values of type JSBFSDirectorySort.
 */
@interface JSBFSDirectorySortConverter: NSObject
@property (class, nonatomic, readonly) JSBFSDirectorySort defaultSort;
- (instancetype)init NS_UNAVAILABLE;
+ (NSURLResourceKey)resourceKeyForSort:(JSBFSDirectorySort)sort;
+ (BOOL)orderedAscendingForSort:(JSBFSDirectorySort)sort;
@end

/*!
 * @discussion Specifies whether updates from JSBFSObservedDirectory should
 *             include modifications in the diff. When modifications are not
 *             included, they appear as a matching set of insertions and deletions
 * @discussion Certain types of collection views support modifications in their
 *             batch update methods and others do not. E.G. UITableView does
 *             but UICollectionView does not.
 */
typedef NS_ENUM(NSInteger, JSBFSObservedDirectoryChangeKind) {
    JSBFSObservedDirectoryChangeKindIncludingModifications,
    JSBFSObservedDirectoryChangeKindModificationsAsInsertionsDeletions,
};

/*!
 * @discussion Allows the desired order of files in a JSBFSDirectory to be specified.
 */
typedef NS_ENUM(NSInteger, JSBFSDirectorySort) {
    JSBFSDirectorySortNameAFirst,
    JSBFSDirectorySortNameZFirst,
    JSBFSDirectorySortCreationNewestFirst,
    JSBFSDirectorySortCreationOldestFirst,
    JSBFSDirectorySortModificationNewestFirst,
    JSBFSDirectorySortModificationOldestFirst
};

typedef void(^JSBFSObservedDirectoryChangeBlock)(JSBFSDirectoryChanges*_Nonnull changes);
typedef BOOL(^JSBFSDirectoryFilterBlock)(NSURL*_Nonnull aURL);
