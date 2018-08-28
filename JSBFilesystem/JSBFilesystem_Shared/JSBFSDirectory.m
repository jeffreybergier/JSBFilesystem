//
//  JSBFSUnobservedDirectory.m
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

#import "JSBFSDirectory.h"
#import "JSBFSFileComparison.h"
#import "NSFileCoordinator+JSBFS.h"
#import "SmallCategories.h"
#import "NSErrors.h"

@implementation JSBFSDirectory

@synthesize url = _url, filteredBy = _filteredBy, sortedBy = _sortedBy;

// MARK: init

- (instancetype _Nullable)initWithBase:(NSSearchPathDirectory)base
                appendingPathComponent:(NSString* _Nullable)pathComponent
                        createIfNeeded:(BOOL)create
                              sortedBy:(JSBFSDirectorySort)sortedBy
                            filteredBy:(NSArray<JSBFSDirectoryFilterBlock>* _Nullable)filters
                                 error:(NSError*_Nullable*)errorPtr;
{
    NSURL* baseURL = [[[NSFileManager defaultManager] URLsForDirectory:base inDomains:NSUserDomainMask] firstObject];
    NSParameterAssert(baseURL);
    NSURL* url = nil;
    if (pathComponent) {
        url = [baseURL URLByAppendingPathComponent:pathComponent];
    } else {
        url = baseURL;
    }
    NSParameterAssert(url);
    self = [self initWithDirectoryURL:url createIfNeeded:create sortedBy:sortedBy filteredBy:filters error:errorPtr];
    return self;
}

- (instancetype _Nullable)initWithDirectoryURL:(NSURL* _Nonnull)url
                                createIfNeeded:(BOOL)create
                                      sortedBy:(JSBFSDirectorySort)sortedBy
                                    filteredBy:(NSArray<JSBFSDirectoryFilterBlock>* _Nullable)filters
                                         error:(NSError*_Nullable*)errorPtr;
{
    NSParameterAssert(url);
    NSParameterAssert(sortedBy >= JSBFSDirectorySortNameAFirst);
    NSParameterAssert(sortedBy <= JSBFSDirectorySortModificationOldestFirst);
    // check if the URL is valid
    NSError* error = nil;
    JSBFSDoubleBool* check = [NSFileCoordinator JSBFS_fileExistsAndIsDirectoryAtURL:url
                                                                      filePresenter:nil
                                                                              error:&error];
    BOOL isExisting = [check value1];
    BOOL isDirectory = [check value2];

    if (error) {
        // if we got an error, bail
        if (errorPtr != NULL) { *errorPtr = error; }
        return nil;
    } else if (isExisting == NO && create == YES) {
        // if the file doesn't exist, and the developer wants us to create it, we need to do that
        [NSFileCoordinator JSBFS_createDirectoryAtURL:url filePresenter:nil error:&error];
    } else if (isExisting == NO && create == NO) {
        // if the file doesn't exist and the developer does not want us to create it we need to fail
        error = [NSError JSBFS_directoryNotFoundAndNotCreated];
    } else if (isExisting == YES && isDirectory == NO) {
        // if the file exists but is not a directory, we can't continue, this class only loads directories
        error = [NSError JSBFS_specifiedURLIsFileExpectedDirectory];
    }
    // one last error check before initializing
    if (error) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return nil;
    }
    // initialize as normal
    self = [super init];
    NSParameterAssert(self);
    self->_sortedBy = sortedBy;
    self->_filteredBy = filters;
    self->_url = url;
    return self;
}

// MARK: -urlAtIndex:error:

- (NSURL*_Nullable)urlAtIndex:(NSUInteger)index error:(NSError*_Nullable*)errorPtr;
{
    NSParameterAssert(index >= 0);
    NSParameterAssert(index < NSNotFound);
    NSArray<JSBFSFileComparison*>* contents = [self sortedAndFilteredComparisons:errorPtr];
    return [[contents objectAtIndex:index] fileURL];
}

// MARK: -deleteContents:

- (BOOL)deleteContents:(NSError*_Nullable*)errorPtr;
{
    NSError* error = nil;
    NSArray<NSURL*>* contents = [self sortedAndFilteredContents:&error];
    if (error || !contents) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return NO;
    }
    BOOL success = [NSFileCoordinator JSBFS_batchDeleteURLs:contents
                                              filePresenter:nil
                                                      error:&error];
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

// MARK: -contentsCount:

- (NSUInteger)contentsCount:(NSError*_Nullable*)errorPtr __attribute__((swift_error(nonnull_error)));
{
    return [[NSFileCoordinator JSBFS_contentsOfDirectoryAtURL:[self url]
                                                     sortedBy:[self sortedBy]
                                                   filteredBy:[self filteredBy]
                                                filePresenter:nil
                                                        error:errorPtr] count];
}

// MARK: -sortedAndFiltered:

- (NSArray<NSURL*>*_Nullable)sortedAndFilteredContents:(NSError*_Nullable*)errorPtr;
{
    NSArray<JSBFSFileComparison*>* comparisons = [self sortedAndFilteredComparisons:errorPtr];
    NSArray<NSURL*>* urls = [comparisons JSBFS_arrayByTransformingArrayContentsWithBlock:
                             ^id _Nonnull(JSBFSFileComparison* item)
                             {
                                 return [item fileURL];
                             }];
    return urls;
}

- (NSArray<JSBFSFileComparison*>*_Nonnull)sortedAndFilteredComparisons:(NSError*_Nullable*)errorPtr;
{
    NSArray* contents = [NSFileCoordinator JSBFS_comparableContentsOfDirectoryAtURL:[self url]
                                                                           sortedBy:[self sortedBy]
                                                                         filteredBy:[self filteredBy]
                                                                      filePresenter:nil
                                                                              error:errorPtr];
    return contents;
}

// MARK: -indexOfItem:error:

- (NSUInteger)indexOfItemWithURL:(NSURL*_Nonnull)rhs error:(NSError*_Nullable*)errorPtr
__attribute__((swift_error(nonnull_error)));
{
    NSParameterAssert(rhs);
    NSError* error = nil;
    NSUInteger index = NSNotFound;
    NSArray<JSBFSFileComparison*>* comparisons = [self sortedAndFilteredComparisons:&error];
    index = [comparisons indexOfObjectPassingTest:
             ^BOOL(JSBFSFileComparison* lhs, NSUInteger idx __attribute__((unused)), BOOL* stop __attribute__((unused)))
             {
                 return [[lhs fileURL] isEqual:rhs];
             }];
    if (error) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return NSNotFound;
    }
    return index;
}

@end
