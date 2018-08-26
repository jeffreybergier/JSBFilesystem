//
//  SmallTypes.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/26/18.
//

#import <Foundation/Foundation.h>

@interface JSBFSDoubleBool: NSObject
@property (readonly, nonatomic) BOOL value1;
@property (readonly, nonatomic) BOOL value2;
- (instancetype)initWithValue1:(BOOL)value1 value2:(BOOL)value2;
@end

typedef BOOL(^JSBFSDirectoryFilterBlock)(NSURL* _Nonnull aURL);

typedef NS_ENUM(NSInteger, JSBFSDirectorySort) {
    JSBFSDirectorySortNameAFirst,
    JSBFSDirectorySortNameZFirst,
    JSBFSDirectorySortCreationNewestFirst,
    JSBFSDirectorySortCreationOldestFirst,
    JSBFSDirectorySortModificationNewestFirst,
    JSBFSDirectorySortModificationOldestFirst
};
