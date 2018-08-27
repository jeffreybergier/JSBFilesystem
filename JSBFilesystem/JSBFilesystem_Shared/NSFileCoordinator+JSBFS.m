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
#import "SmallCategories.h"
#import "NSErrors.h"

@implementation NSFileCoordinator (JSBFS)

+ (BOOL)JSBFS_writeData:(NSData*_Nonnull)data
                  toURL:(NSURL*_Nonnull)url
          filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                  error:(NSError*_Nullable*)errorPtr;
{
    __block NSError* error = nil;
    __block BOOL success = NO;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] initWithFilePresenter:filePresenter];
    [c coordinateWritingItemAtURL:url
                          options:NSFileCoordinatorWritingForReplacing
                            error:&error
                       byAccessor:^(NSURL * _Nonnull newURL)
    {
        if (error) { return; }
        success = [data writeToURL:newURL options:NSDataWritingAtomic error:&error];
    }];
    if (error) {
        if (errorPtr != NULL) { *errorPtr = error; }
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
    __block NSError* error = nil;
    __block BOOL success = NO;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] initWithFilePresenter:filePresenter];
    [c coordinateWritingItemAtURL:url
                          options:NSFileCoordinatorWritingForReplacing
                            error:&error
                       byAccessor:^(NSURL * _Nonnull newURL)
     {
         if (error) { return; }
         success = [fileWrapper writeToURL:newURL
                                   options:NSFileWrapperWritingAtomic
                       originalContentsURL:nil error:&error];
     }];
    if (error) {
        if (errorPtr != NULL) { *errorPtr = error; }
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
    __block NSError* error = nil;
    __block NSData* data = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] initWithFilePresenter:filePresenter];
    [c coordinateReadingItemAtURL:url
                          options:NSFileCoordinatorReadingResolvesSymbolicLink
                            error:&error
                       byAccessor:^(NSURL * _Nonnull newURL)
    {
        if (error) { return; }
        data = [NSData dataWithContentsOfURL:newURL options:0 error:&error];
    }];
    if (error) {
        if (errorPtr != NULL) { *errorPtr = error; }
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
    __block NSError* error = nil;
    __block NSFileWrapper* fileWrapper = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] initWithFilePresenter:filePresenter];
    [c coordinateReadingItemAtURL:url
                          options:NSFileCoordinatorReadingResolvesSymbolicLink
                            error:&error
                       byAccessor:^(NSURL * _Nonnull newURL)
     {
         if (error) { return; }
         fileWrapper = [[NSFileWrapper alloc] initWithURL:newURL
                                                  options:NSFileWrapperReadingImmediate
                                                    error:&error];
     }];
    if (error) {
        if (errorPtr != NULL) { *errorPtr = error; }
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
    __block NSError* error = nil;
    __block BOOL success = NO;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] initWithFilePresenter:filePresenter];
    [c coordinateWritingItemAtURL:url
                          options:NSFileCoordinatorWritingForDeleting
                            error:&error
                       byAccessor:^(NSURL * _Nonnull newURL)
     {
         if (error) { return; }
        #if TARGET_OS_IPHONE
         success = [[NSFileManager defaultManager] removeItemAtURL:newURL error:&error];
        #else
         success = [[NSFileManager defaultManager] trashItemAtURL:newURL resultingItemURL:nil error:&error];
        #endif
     }];
    if (error) {
        if (errorPtr != NULL) { *errorPtr = error; }
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
    __block NSError* error = nil;
    __block BOOL success = YES;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] initWithFilePresenter:filePresenter];
    [c prepareForReadingItemsAtURLs:contents
                            options:0
                 writingItemsAtURLs:contents
                            options:NSFileCoordinatorWritingForDeleting
                              error:&error
                         byAccessor:^(void (^ _Nonnull completionHandler)(void))
     {
         // if an error ocurred before we start looping, bail
         if (error || !success) {
             completionHandler();
             return;
         }
         for (NSURL* item in contents) {
             // if an error ocurred while looping, bail from the loop
             if (error || !success) {
                 completionHandler();
                 break;
             }
             [self JSBFS_deleteURL:item filePresenter:filePresenter error:&error];
         }
         // if everything went well, call the completion handler
         completionHandler();
     }];
    if (error) {
        if (errorPtr != NULL) { *errorPtr = error; }
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
    __block NSError* error = nil;
    __block BOOL success = NO;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] initWithFilePresenter:filePresenter];
    [c coordinateWritingItemAtURL:url
                          options:NSFileCoordinatorWritingForReplacing
                            error:&error
                       byAccessor:^(NSURL * _Nonnull newURL)
     {
         if (error) { return; }
         success = [[NSFileManager defaultManager] createDirectoryAtURL:newURL
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:&error];
     }];
    if (error) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return NO;
    } else if (!success) {
        if (errorPtr != NULL) { *errorPtr = [NSError JSBFS_operationFailedButNoCocoaErrorThrown]; }
        return NO;
    } else {
        return YES;
    }
}

+ (NSArray<NSURL*>*_Nullable)JSBFS_contentsOfDirectoryAtURL:(NSURL*_Nonnull)url
                                                   sortedBy:(JSBFSDirectorySort)sortedBy
                                                 filteredBy:(NSArray<JSBFSDirectoryFilterBlock>*_Nullable)_filters
                                              filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                                                      error:(NSError*_Nullable*)errorPtr;
{
    __block NSError* error = nil;
    __block NSArray<NSURL*>* contents = nil;
    __block NSArray<JSBFSDirectoryFilterBlock>* filters = _filters;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] initWithFilePresenter:filePresenter];
    [c prepareForReadingItemsAtURLs:contents
                            options:NSFileCoordinatorReadingResolvesSymbolicLink
                 writingItemsAtURLs:@[]
                            options:0
                              error:&error
                         byAccessor:^(void (^ _Nonnull completionHandler)(void))
     {
         if (error) { return; }
         [c coordinateReadingItemAtURL:url
                               options:NSFileCoordinatorReadingResolvesSymbolicLink
                                 error:&error
                            byAccessor:^(NSURL * _Nonnull newURL)
         {
             if (error) { completionHandler(); return; }
             NSArray<NSURL*>* allContents =
             [[NSFileManager defaultManager] contentsOfDirectoryAtURL:newURL
                                           includingPropertiesForKeys:@[NSURLLocalizedNameKey, NSURLContentModificationDateKey, NSURLCreationDateKey]
                                                              options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                error:&error];
             if (error) { completionHandler(); return; }
             NSArray<NSURL*>* unsortedContents = [self __JSBFS_filterContents:allContents withFilters:filters];
             NSURLResourceKey resourceKey = [JSBFSDirectorySortConverter resourceKeyForSort:sortedBy];
             BOOL ascending = [JSBFSDirectorySortConverter orderedAscendingForSort:sortedBy];
             contents = [self __JSBFS_sortContents:[unsortedContents mutableCopy]
                               sortedByResourceKey:resourceKey
                                  orderedAscending:ascending
                                             error:&error];
         }];
         completionHandler();
     }];
    // check if that operation failed
    if (error) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return nil;
    } else if (!contents) {
        if (errorPtr != NULL) { *errorPtr = [NSError JSBFS_operationFailedButNoCocoaErrorThrown]; }
        return nil;
    } else {
        return contents;
    }
}

+ (NSArray<JSBFSFileComparison*>* _Nullable)JSBFS_urlComparisonsForFilesInDirectoryURL:(NSURL*_Nonnull)url
                                                                              sortedBy:(JSBFSDirectorySort)sortedBy
                                                                            filteredBy:(NSArray<JSBFSDirectoryFilterBlock>*_Nullable)filters
                                                                         filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                                                                                 error:(NSError*_Nullable*)errorPtr;
{
    NSError* error = nil;
    NSArray<NSURL*>* contents = [self JSBFS_contentsOfDirectoryAtURL:url
                                                           sortedBy:sortedBy
                                                         filteredBy:filters
                                                      filePresenter:filePresenter
                                                              error:&error];
    BOOL success = [contents count] == 0 ? YES : NO;
    NSMutableArray<JSBFSFileComparison*>* values = [[NSMutableArray alloc] initWithCapacity:[contents count]];
    for (NSURL* contentURL in contents) {
        NSDate* modDate = nil;
        success = [contentURL getResourceValue:&modDate forKey:NSURLContentModificationDateKey error:&error];
        if (error || !modDate || !success) { break; }
        JSBFSFileComparison* value = [[JSBFSFileComparison alloc] initWithFileURL:contentURL modificationDate:modDate];
        [values addObject:value];
    }
    if (error) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return nil;
    } else if (([values count] != [contents count]) || (!success)) {
        if (errorPtr != NULL) { *errorPtr = [NSError JSBFS_operationFailedButNoCocoaErrorThrown]; }
        return nil;
    } else {
        return values;
    }
}


+ (JSBFSDoubleBool*)JSBFS_fileExistsAndIsDirectoryAtURL:(NSURL*)url error:(NSError**)errorPtr;
{
    NSError* outerError = nil;
    __block NSError* innerError = nil;
    __block JSBFSDoubleBool* value = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateReadingItemAtURL:url
                          options:NSFileCoordinatorReadingResolvesSymbolicLink
                            error:&outerError
                       byAccessor:^(NSURL* _Nonnull newURL)
     {
         BOOL isDirectory = NO;
         BOOL isExisting = [[NSFileManager defaultManager] fileExistsAtPath:[newURL path] isDirectory:&isDirectory];
         value = [[JSBFSDoubleBool alloc] initWithValue1:isExisting value2:isDirectory];
     }];
    if (outerError) {
        if (errorPtr != NULL) { *errorPtr = outerError; }
        return nil;
    } else if (innerError || !value) {
        if (errorPtr != NULL) { *errorPtr = innerError; }
        return nil;
    } else {
        return value;
    }
}

+   (BOOL)JSBFS_executeBlock:(void (^_Nonnull)(void))executionBlock
whileCoordinatingAccessAtURL:(NSURL* _Nonnull)url
                       error:(NSError* _Nullable*)errorPtr;
{
    __block NSError* error = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateReadingItemAtURL:url
                          options:NSFileCoordinatorReadingResolvesSymbolicLink
                            error:&error
                       byAccessor:^(NSURL* _Nonnull newURL)
     {
         executionBlock();
     }];
    if (error) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return NO;
    } else {
        return YES;
    }
}

+ (NSArray<NSURL*>*_Nullable)__JSBFS_sortContents:(NSMutableArray<NSURL*>*_Nonnull)contents
                              sortedByResourceKey:(NSURLResourceKey)resourceKey
                                 orderedAscending:(BOOL)ascending
                                            error:(NSError*_Nullable*)errorPtr;
{
    BOOL sortRequired = [contents count] >= 2;
    __block NSError* error = nil;
    __block BOOL lhsSuccess = sortRequired ? NO : YES;
    __block BOOL rhsSuccess = sortRequired ? NO : YES;
    [contents sortUsingComparator:^NSComparisonResult(NSURL* _Nonnull lhs, NSURL* _Nonnull rhs) {
        if ([resourceKey isEqualToString:NSURLLocalizedNameKey]) {
            NSString* lhsName = nil;
            NSString* rhsName = nil;
            lhsSuccess = [lhs getResourceValue:&lhsName forKey:resourceKey error:&error];
            rhsSuccess = [rhs getResourceValue:&rhsName forKey:resourceKey error:&error];
            if (error || !lhsSuccess || !rhsSuccess || !lhsName || !rhsName) { return NSOrderedSame; }
            if (ascending) {
                return [lhsName localizedCaseInsensitiveCompare:rhsName];
            } else {
                return [rhsName localizedCaseInsensitiveCompare:lhsName];
            }
        } else if ([resourceKey isEqualToString:NSURLContentModificationDateKey] || [resourceKey isEqualToString:NSURLCreationDateKey]) {
            NSDate* lhsDate = nil;
            NSDate* rhsDate = nil;
            lhsSuccess = [lhs getResourceValue:&lhsDate forKey:resourceKey error:&error];
            rhsSuccess = [rhs getResourceValue:&rhsDate forKey:resourceKey error:&error];
            if (error || !lhsSuccess || !rhsSuccess || !lhsDate || !rhsDate) { return NSOrderedSame; }
            if (ascending) {
                return [lhsDate compare:rhsDate];
            } else {
                return [rhsDate compare:lhsDate];
            }
        } else {
            @throw [[NSException alloc] initWithName:@"Unsupported NSURLResourceKey" reason:@"This function only supports NSURLLocalizedNameKey, NSURLContentModificationDateKey, NSURLCreationDateKey" userInfo:nil];
        }
    }];
    if (error) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return nil;
    } else if (!lhsSuccess || !rhsSuccess) {
        if (errorPtr != NULL) { *errorPtr = [NSError JSBFS_operationFailedButNoCocoaErrorThrown]; }
        return nil;
    } else {
        return [contents copy];
    }
}

+ (NSArray<NSURL*>*_Nonnull)__JSBFS_filterContents:(NSArray<NSURL*>*_Nonnull)allContents
                                       withFilters:(NSArray<JSBFSDirectoryFilterBlock>*_Nullable)filters;
{
    NSArray<NSURL*>* contents = nil;
    if ((!filters) || ([filters count] == 0)) {
        // if there are no filters, bail out
        contents = allContents;
    } else {
        // if there are filters, we need to do several things
        // 1) filter the contents of the array using our Array of test Blocks
        contents = [allContents JSBFS_arrayByFilteringArrayContentsWithBlock:^BOOL(id item) {
            // 2) Map the filters array into an array of NSNumber objects that represent a YES/NO for passing the filter
            // This could be optimized to bail out if a test returns NO, but for now, that optimization is not present
            NSArray<NSNumber*>* testResult = [filters JSBFS_arrayByTransformingArrayContentsWithBlock:^id _Nonnull(id _block) {
                JSBFSDirectoryFilterBlock block = _block;
                BOOL test = block(item);
                return [NSNumber numberWithBool:test];
            }];
            // 3) we want to AND the answers together
            // They have to be all YES or it doesn't pass
            // We will just check if a NO was ever present
            // If it was we flag it
            BOOL noWasPresent = NO;
            for (NSNumber* number in testResult) {
                BOOL result = [number boolValue];
                if (!result) {
                    noWasPresent = YES;
                    break;
                }
            }
            // 4) check if NO was ever present
            // if it was, then they do not pass and should be filtered out
            if (noWasPresent) {
                return NO;
            } else {
                return YES;
            }
        }];
    }
    return contents;
}

@end
