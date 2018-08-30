//
//  NSFileCoordinator+JSBFS.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 27/07/2018.
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

#import "NSFileCoordinator+JSBFS.h"
#import "JSBFSFileComparison.h"
#import "SmallTypes.h"
#import "NSErrors.h"

@implementation NSFileCoordinator (JSBFS)

+ (BOOL)JSBFS_writeData:(NSData*_Nonnull)data
                  toURL:(NSURL*_Nonnull)url
          filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                  error:(NSError*_Nullable*)errorPtr;
{
    NSParameterAssert(data);
    NSParameterAssert(url);
    NSError* coError = nil;
    __block NSError* opError = nil;
    __block BOOL success = NO;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] initWithFilePresenter:filePresenter];
    [c coordinateWritingItemAtURL:url
                          options:NSFileCoordinatorWritingForReplacing
                            error:&coError
                       byAccessor:^(NSURL*_Nonnull newURL)
    {
        success = [data writeToURL:newURL options:NSDataWritingAtomic error:&opError];
    }];
    if (coError) {
        if (errorPtr != NULL) { *errorPtr = coError; }
        return NO;
    } else if (opError) {
        if (errorPtr != NULL) { *errorPtr = opError; }
        return NO;
    } else if (!success) {
        if (errorPtr != NULL) { *errorPtr = [NSError JSBFS_operationFailedButNoCocoaErrorThrown]; }
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)JSBFS_writeFileWrapper:(NSFileWrapper*_Nonnull)fileWrapper
                         toURL:(NSURL*_Nonnull)url
                 filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                         error:(NSError*_Nullable*)errorPtr;
{
    NSParameterAssert(fileWrapper);
    NSParameterAssert(url);
    NSError* coError = nil;
    __block NSError* opError = nil;
    __block BOOL success = NO;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] initWithFilePresenter:filePresenter];
    [c coordinateWritingItemAtURL:url
                          options:NSFileCoordinatorWritingForReplacing
                            error:&coError
                       byAccessor:^(NSURL*_Nonnull newURL)
     {
         success = [fileWrapper writeToURL:newURL
                                   options:NSFileWrapperWritingAtomic
                       originalContentsURL:nil
                                     error:&opError];
     }];
    if (coError) {
        if (errorPtr != NULL) { *errorPtr = coError; }
        return NO;
    } else if (opError) {
        if (errorPtr != NULL) { *errorPtr = opError; }
        return NO;
    } else if (!success) {
        if (errorPtr != NULL) { *errorPtr = [NSError JSBFS_operationFailedButNoCocoaErrorThrown]; }
        return NO;
    } else {
        return YES;
    }
}

+ (NSData*_Nullable)JSBFS_readDataFromURL:(NSURL*_Nonnull)url
                            filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                                    error:(NSError*_Nullable*)errorPtr;
{
    NSParameterAssert(url);
    NSError* coError = nil;
    __block NSError* opError = nil;
    __block NSData* data = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] initWithFilePresenter:filePresenter];
    [c coordinateReadingItemAtURL:url
                          options:NSFileCoordinatorReadingResolvesSymbolicLink
                            error:&coError
                       byAccessor:^(NSURL*_Nonnull newURL)
    {
        data = [NSData dataWithContentsOfURL:newURL options:0 error:&opError];
    }];
    if (coError) {
        if (errorPtr != NULL) { *errorPtr = coError; }
        return nil;
    } else if (opError) {
        if (errorPtr != NULL) { *errorPtr = opError; }
        return nil;
    } else if (!data) {
        if (errorPtr != NULL) { *errorPtr = [NSError JSBFS_operationFailedButNoCocoaErrorThrown]; }
        return nil;
    } else {
        return data;
    }
}

+ (NSFileWrapper* _Nullable)JSBFS_readFileWrapperFromURL:(NSURL* _Nonnull)url
                                           filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                                                   error:(NSError* _Nullable*)errorPtr;
{
    NSParameterAssert(url);
    NSError* coError = nil;
    __block NSError* opError = nil;
    __block NSFileWrapper* fileWrapper = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] initWithFilePresenter:filePresenter];
    [c coordinateReadingItemAtURL:url
                          options:NSFileCoordinatorReadingResolvesSymbolicLink
                            error:&coError
                       byAccessor:^(NSURL*_Nonnull newURL)
     {
         fileWrapper = [[NSFileWrapper alloc] initWithURL:newURL
                                                  options:NSFileWrapperReadingImmediate
                                                    error:&opError];
     }];
    if (coError) {
        if (errorPtr != NULL) { *errorPtr = coError; }
        return nil;
    } else if (opError) {
        if (errorPtr != NULL) { *errorPtr = opError; }
        return nil;
    } else if (!fileWrapper) {
        if (errorPtr != NULL) { *errorPtr = [NSError JSBFS_operationFailedButNoCocoaErrorThrown]; }
        return nil;
    } else {
        return fileWrapper;
    }
}

+ (BOOL)JSBFS_deleteURL:(NSURL*_Nonnull)url
          filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                  error:(NSError*_Nullable*)errorPtr;
{
    NSParameterAssert(url);
    NSError* coError = nil;
    __block NSError* opError = nil;
    __block BOOL success = NO;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] initWithFilePresenter:filePresenter];
    [c coordinateWritingItemAtURL:url
                          options:NSFileCoordinatorWritingForDeleting
                            error:&coError
                       byAccessor:^(NSURL*_Nonnull newURL)
     {
        #if TARGET_OS_IPHONE
         success = [[NSFileManager defaultManager] removeItemAtURL:newURL error:&opError];
        #else
         success = [[NSFileManager defaultManager] trashItemAtURL:newURL resultingItemURL:nil error:&opError];
        #endif
     }];
    if (coError) {
        if (errorPtr != NULL) { *errorPtr = coError; }
        return NO;
    } else if (opError) {
        if (errorPtr != NULL) { *errorPtr = opError; }
        return NO;
    } else if (!success) {
        if (errorPtr != NULL) { *errorPtr = [NSError JSBFS_operationFailedButNoCocoaErrorThrown]; }
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)JSBFS_batchDeleteURLs:(NSArray<NSURL*>*_Nonnull)contents
                filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                        error:(NSError*_Nullable*)errorPtr;
{
    // if there is no Array or its empty, bail early with success.
    if (!contents || [contents count] == 0) {
        return YES;
    }
    NSError* coError = nil;
    __block NSError* opError = nil;
    __block BOOL success = YES;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] initWithFilePresenter:filePresenter];
    [c prepareForReadingItemsAtURLs:contents
                            options:NSFileCoordinatorReadingResolvesSymbolicLink
                 writingItemsAtURLs:contents
                            options:NSFileCoordinatorWritingForDeleting
                              error:&coError
                         byAccessor:^(void (^_Nonnull completionHandler)(void))
     {
         for (NSURL* item in contents) {
             if (opError || !success) { break; }
             success = [self JSBFS_deleteURL:item filePresenter:filePresenter error:&opError];
         }
         completionHandler();
     }];
    if (coError) {
        if (errorPtr != NULL) { *errorPtr = coError; }
        return NO;
    } if (opError) {
        if (errorPtr != NULL) { *errorPtr = opError; }
        return NO;
    } else if (!success) {
        if (errorPtr != NULL) { *errorPtr = [NSError JSBFS_operationFailedButNoCocoaErrorThrown]; }
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)JSBFS_createDirectoryAtURL:(NSURL*_Nonnull)url
                     filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                             error:(NSError*_Nullable*)errorPtr;
{
    NSParameterAssert(url);
    NSError* coError = nil;
    __block NSError* opError = nil;
    __block BOOL success = NO;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] initWithFilePresenter:filePresenter];
    [c coordinateWritingItemAtURL:url
                          options:NSFileCoordinatorWritingForReplacing
                            error:&coError
                       byAccessor:^(NSURL*_Nonnull newURL)
     {
         success = [[NSFileManager defaultManager] createDirectoryAtURL:newURL
                                            withIntermediateDirectories:YES
                                                             attributes:nil
                                                                  error:&opError];
     }];
    if (coError) {
        if (errorPtr != NULL) { *errorPtr = coError; }
        return NO;
    } if (opError) {
        if (errorPtr != NULL) { *errorPtr = opError; }
        return NO;
    } else if (!success) {
        if (errorPtr != NULL) { *errorPtr = [NSError JSBFS_operationFailedButNoCocoaErrorThrown]; }
        return NO;
    } else {
        return YES;
    }
}


+ (JSBFSDoubleBool*_Nullable)JSBFS_fileExistsAndIsDirectoryAtURL:(NSURL*_Nonnull)url
                                                   filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                                                           error:(NSError*_Nullable*)errorPtr;
{
    NSParameterAssert(url);
    NSError* coError = nil;
    __block JSBFSDoubleBool* value = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] initWithFilePresenter:filePresenter];
    [c coordinateReadingItemAtURL:url
                          options:NSFileCoordinatorReadingResolvesSymbolicLink
                            error:&coError
                       byAccessor:^(NSURL*_Nonnull newURL)
     {
         BOOL isDirectory = NO;
         BOOL isExisting = [[NSFileManager defaultManager] fileExistsAtPath:[newURL path]
                                                                isDirectory:&isDirectory];
         value = [[JSBFSDoubleBool alloc] initWithValue1:isExisting
                                                  value2:isDirectory];
     }];
    if (coError) {
        if (errorPtr != NULL) { *errorPtr = coError; }
        return nil;
    } else if (!value) {
        if (errorPtr != NULL) { *errorPtr = [NSError JSBFS_operationFailedButNoCocoaErrorThrown]; }
        return nil;
    } else {
        return value;
    }
}

@end
