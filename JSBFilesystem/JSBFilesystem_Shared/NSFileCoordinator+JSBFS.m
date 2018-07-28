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
    NSError* outerError = nil;
    __block NSError* innerError = nil;
    __block BOOL innerSuccess = NO;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateWritingItemAtURL:url
                          options:NSFileCoordinatorWritingForReplacing
                            error:&outerError
                       byAccessor:^(NSURL * _Nonnull newURL)
    {
        innerSuccess = [data writeToURL:newURL options:NSDataWritingAtomic error:&innerError];
    }];
    if (outerError != NULL) {
        *errorPtr = outerError;
        return NO;
    } else if (innerError != NULL || !innerSuccess) {
        *errorPtr = innerError;
        return NO;
    } else {
        return YES;
    }
}

+ (NSData*)JSBFS_readDataFromURL:(NSURL*)url
                           error:(NSError**)errorPtr;
{
    NSError* outerError = nil;
    __block NSError* innerError = nil;
    __block NSData* data = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateReadingItemAtURL:url
                          options:NSFileCoordinatorReadingResolvesSymbolicLink
                            error:&outerError
                       byAccessor:^(NSURL * _Nonnull newURL)
    {
        data = [NSData dataWithContentsOfURL:newURL options:0 error:&innerError];
    }];
    if (outerError != NULL) {
        *errorPtr = outerError;
        return nil;
    } else if (innerError != NULL || data == nil) {
        *errorPtr = innerError;
        return nil;
    } else {
        return data;
    }
}

+ (BOOL)JSBFS_recursivelyDeleteDirectoryOrFileAtURL:(NSURL*)url
                                              error:(NSError**)errorPtr;
{
    NSError* outerError = nil;
    __block NSError* innerError = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateWritingItemAtURL:url
                          options:NSFileCoordinatorWritingForDeleting
                            error:&outerError
                       byAccessor:^(NSURL * _Nonnull newURL)
     {
         [[NSFileManager defaultManager] trashItemAtURL:newURL resultingItemURL:nil error:&innerError];
     }];
    if (outerError != NULL) {
        *errorPtr = outerError;
        return NO;
    } else if (innerError != NULL) {
        *errorPtr = innerError;
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)JSBFS_moveSourceFileURL:(NSURL*)sourceURL
           toDestinationFileURL:(NSURL*)destinationURL
                          error:(NSError**)errorPtr;
{
    NSError* outerError = nil;
    __block NSError* innerError = nil;
    __block BOOL innerSuccess = NO;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateReadingItemAtURL:sourceURL
                          options:0
                 writingItemAtURL:destinationURL
                          options:NSFileCoordinatorWritingForReplacing << NSFileCoordinatorWritingForMoving
                            error:&outerError
                       byAccessor:^(NSURL * _Nonnull newReadingURL, NSURL * _Nonnull newWritingURL)
     {
         NSFileManager* fm = [NSFileManager defaultManager];
         NSURL* parentDir = [newWritingURL URLByDeletingLastPathComponent];
         innerSuccess = [fm createDirectoryAtURL:parentDir withIntermediateDirectories:YES attributes:nil error:&innerError];
         if (!innerSuccess || innerError != nil) { return; }
         innerSuccess = [fm moveItemAtURL:newReadingURL toURL:newWritingURL error:&innerError];
     }];
    if (outerError != NULL) {
        *errorPtr = outerError;
        return NO;
    } else if (innerError != NULL || !innerSuccess) {
        *errorPtr = innerError;
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)JSBFS_createDirectoryAtURL:(NSURL* _Nonnull)url
                             error:(NSError* _Nullable*)errorPtr;
{
    NSError* outerError = nil;
    __block NSError* innerError = nil;
    __block BOOL innerSuccess = NO;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateWritingItemAtURL:url
                          options:NSFileCoordinatorWritingForReplacing
                            error:&outerError
                       byAccessor:^(NSURL * _Nonnull newURL)
     {
         innerSuccess = [[NSFileManager defaultManager] createDirectoryAtURL:newURL withIntermediateDirectories:YES attributes:nil error:&innerError];
     }];
    if (outerError != NULL) {
        *errorPtr = outerError;
        return NO;
    } else if (innerError != NULL || !innerSuccess) {
        *errorPtr = innerError;
        return NO;
    } else {
        return YES;
    }
}

+ (NSInteger)JSBFS_fileCountInDirectoryURL:(NSURL*)url
                                     error:(NSError**)errorPtr;
{

    __block NSError* outerError = nil;
    __block NSError* innerError = nil;
    __block NSArray<NSURL*>* contents = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateReadingItemAtURL:url
                          options:NSFileCoordinatorReadingResolvesSymbolicLink
                            error:&outerError
                       byAccessor:^(NSURL* _Nonnull newURL)
     {
         contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url
                                       includingPropertiesForKeys:nil
                                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                                            error:&outerError];
     }];
    if (outerError != NULL) {
        *errorPtr = outerError;
        return 0;
    } else if (innerError != NULL || contents == nil) {
        *errorPtr = innerError;
        return 0;
    } else {
        return [contents count];
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
