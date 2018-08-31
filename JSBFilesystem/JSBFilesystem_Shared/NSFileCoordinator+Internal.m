//
//  NSFileCoordinator+Internal.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/30/18.
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

#import "NSFileCoordinator+Internal.h"
#import "JSBFSFileComparison.h"
#import "SmallTypes.h"
#import "NSErrors.h"

@implementation NSFileCoordinator (Internal)

+ (NSArray<NSURL*>*_Nullable)JSBFS_contentsOfDirectoryAtURL:(NSURL*_Nonnull)url
                                                   sortedBy:(JSBFSDirectorySort)sortedBy
                                                 filteredBy:(NSArray<JSBFSDirectoryFilterBlock>*_Nullable)_filters
                                              filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                                                      error:(NSError*_Nullable*)errorPtr;
{
    NSParameterAssert(url);
    NSParameterAssert(sortedBy >= JSBFSDirectorySortNameAFirst);
    NSParameterAssert(sortedBy <= JSBFSDirectorySortModificationOldestFirst);
    __block NSError* coError = nil;
    __block NSError* opError = nil;
    __block NSArray<NSURL*>* contents = nil;
    __block NSArray<JSBFSDirectoryFilterBlock>* filters = _filters;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] initWithFilePresenter:filePresenter];
    [c prepareForReadingItemsAtURLs:contents
                            options:NSFileCoordinatorReadingResolvesSymbolicLink
                 writingItemsAtURLs:@[]
                            options:0
                              error:&coError
                         byAccessor:^(void (^_Nonnull completionHandler)(void))
     {
         NSArray<NSURL*>* allUnsortedContents =
         [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url
                                       includingPropertiesForKeys:@[NSURLLocalizedNameKey,
                                                                    NSURLContentModificationDateKey,
                                                                    NSURLCreationDateKey]
                                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                                            error:&opError];
         if (opError) { completionHandler(); return; }
         NSURLResourceKey resourceKey = [JSBFSDirectorySortConverter resourceKeyForSort:sortedBy];
         BOOL ascending = [JSBFSDirectorySortConverter orderedAscendingForSort:sortedBy];
         NSArray<NSURL*>* allSortedContents = [self __JSBFS_sortContents:[allUnsortedContents mutableCopy]
                                                     sortedByResourceKey:resourceKey
                                                        orderedAscending:ascending
                                                                   error:&opError];
         if (opError) { completionHandler(); return; }
         contents = [self __JSBFS_filterContents:allSortedContents
                                     withFilters:filters
                                   filePresenter:filePresenter
                                           error:&opError];
         if (opError) { completionHandler(); return; }
         completionHandler();
     }];
    if (coError) {
        if (errorPtr != NULL) { *errorPtr = coError; }
        return nil;
    } if (opError) {
        if (errorPtr != NULL) { *errorPtr = opError; }
        return nil;
    } else if (!contents) {
        if (errorPtr != NULL) { *errorPtr = [NSError JSBFS_operationFailedButNoCocoaErrorThrown]; }
        return nil;
    } else {
        return contents;
    }
}

+ (NSArray<JSBFSFileComparison*>* _Nullable)JSBFS_comparableContentsOfDirectoryAtURL:(NSURL*_Nonnull)url
                                                                            sortedBy:(JSBFSDirectorySort)sortedBy
                                                                          filteredBy:(NSArray<JSBFSDirectoryFilterBlock>*_Nullable)filters
                                                                       filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                                                                               error:(NSError*_Nullable*)errorPtr;
{
    NSParameterAssert(url);
    NSParameterAssert(sortedBy >= JSBFSDirectorySortNameAFirst);
    NSParameterAssert(sortedBy <= JSBFSDirectorySortModificationOldestFirst);
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
    } else if (!success) {
        if (errorPtr != NULL) { *errorPtr = [NSError JSBFS_operationFailedButNoCocoaErrorThrown]; }
        return nil;
    } else {
        return values;
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
            @throw [NSException JSBFS_unsupportedURLResourceKey];
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

+ (NSArray<NSURL*>*_Nullable)__JSBFS_filterContents:(NSArray<NSURL*>*_Nonnull)allContents
                                        withFilters:(NSArray<JSBFSDirectoryFilterBlock>*_Nullable)filters
                                      filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                                              error:(NSError*_Nullable*)errorPtr;
{
    if ((!filters) || ([filters count] == 0)) { return allContents; }
    NSMutableArray<NSURL*>* contents = [[NSMutableArray alloc] init];
    NSError* coError = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] initWithFilePresenter:filePresenter];
    for (NSURL* oldURL in allContents) {
        [c coordinateReadingItemAtURL:oldURL
                              options:NSFileCoordinatorReadingResolvesSymbolicLink
                                error:&coError
                           byAccessor:^(NSURL*_Nonnull newURL)
         {
             BOOL allFiltersPass = YES;
             for (JSBFSDirectoryFilterBlock filter in filters) {
                 // stop executing filters if one fails
                 if (!allFiltersPass) { break; }
                 allFiltersPass = filter(newURL);
             }
             // if they all pass, add the object for output
             if (allFiltersPass) {
                 [contents addObject:newURL];
             }
         }];
    }
    if (coError) {
        if (errorPtr != NULL) { *errorPtr = coError; }
        return nil;
    } else {
        return [contents copy];
    }
}

@end
