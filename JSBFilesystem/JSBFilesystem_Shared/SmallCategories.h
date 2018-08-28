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
typedef NS_ENUM(NSInteger, JSBFSDirectorySort);


@interface NSArray (JSBFS)
/*!
 * @discussion A simple, untyped map operation for NSArray. Throws an exception
 *             if input and output arrays counts do not match.
 * @param transform A block that allows you to transform the existing object
 *        into a new object.
 * @return An array of equal length as the original array, populated with the
 *         transformed objects. If the original array was Mutable, the returned
 *         array will also mutable.
 */
- (NSArray*)JSBFS_arrayByTransformingArrayContentsWithBlock:(id _Nonnull (^_Nonnull)(id item))transform
NS_SWIFT_NAME(JSBFS_transformingArrayContents(withTransform:));
/*!
 * @discussion A simple, untyped filter operation for NSArray.
 * @param isIncluded A filter block. Return YES to keep object, return NO to filter object.
 * @return An array with the filtered objects removed. If the original array
 *         was Mutable, the returned array will also mutable.
 */
- (NSArray*)JSBFS_arrayByFilteringArrayContentsWithBlock:(BOOL (^_Nonnull)(id item))isIncluded
NS_SWIFT_NAME(JSBFS_filteringArrayContents(_:));
@end

@interface NSOperationQueue (JSBFS)
/*!
 * @discussion Internal method to create a new NSOperationQueue to be used by
 *             JSBFSObservedDirectory and NSFilePresenter.
 * @return A new NSOperationQueue instance with an underlying serial queue
 *         that allows only 1 concurrent operation.
 */
+ (instancetype _Nonnull)JSBFS_serialQueue;
@end
