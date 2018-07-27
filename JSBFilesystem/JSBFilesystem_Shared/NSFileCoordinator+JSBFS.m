//
//  NSFileCoordinator+JSBFS.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 27/07/2018.
//

#import "NSFileCoordinator+JSBFS.h"

@implementation NSFileCoordinator (JSBFS)

+ (BOOL)JSBFS_writeData:(NSData*)data toURL:(NSURL*)url error:(NSError**)errorPtr;
{
    NSError*__autoreleasing* coordinationError = nil;
    NSError*__autoreleasing* writeError = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateWritingItemAtURL:url
                          options:NSFileCoordinatorWritingForReplacing
                            error:coordinationError
                       byAccessor:^(NSURL * _Nonnull newURL)
    {
        [data writeToURL:url options:NSDataWritingAtomic error:writeError];
    }];
    if (coordinationError != NULL) {
        errorPtr = coordinationError;
        return NO;
    } else if (writeError != NULL) {
        errorPtr = writeError;
        return NO;
    } else {
        return YES;
    }
}

@end

@implementation JSBFSDoubleBool
- (instancetype)initWithValue1:(BOOL)value1 value2:(BOOL)value2;
{
    if (self = [super init]) {
        _value1 = value1;
        _value2 = value2;
    }
    return self;
}
@end
