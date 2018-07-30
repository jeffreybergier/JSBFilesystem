//
//  SmallCategories.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 30/07/2018.
//

@import Foundation;

@interface NSArray (JSBFS)
/// Returns an immutable array if the original array is immutable
/// Returns a mutable array if the original array is mutable
- (NSArray*)JSBFS_arrayByTransformingArrayContentsWithBlock:(id _Nonnull (^_Nonnull)(id item))transform;
@end
