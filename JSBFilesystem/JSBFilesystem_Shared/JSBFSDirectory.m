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
#import "NSFileCoordinator+JSBFS.h"
#import "SmallCategories.h"

@implementation JSBFSDirectory

// MARK: init

- (instancetype)initWithBase:(NSSearchPathDirectory)base
      appendingPathComponent:(NSString*)pathComponent
              createIfNeeded:(BOOL)create
                    sortedBy:(JSBFSDirectorySort)sortedBy
                       error:(NSError**)errorPtr;
{
    NSURL* baseURL = [[[NSFileManager defaultManager] URLsForDirectory:base inDomains:NSUserDomainMask] firstObject];
    NSURL* url = nil;
    if (pathComponent) {
        url = [baseURL URLByAppendingPathComponent:pathComponent];
    } else {
        url = baseURL;
    }
    if (!url) {
        if (errorPtr != NULL) { *errorPtr = [[NSError alloc] initWithDomain:@"" code:0 userInfo:nil]; }
        return nil;
    }
    self = [self initWithDirectoryURL:url createIfNeeded:create sortedBy:sortedBy error:errorPtr];
    return self;
}

- (instancetype)initWithDirectoryURL:(NSURL*)url
                                createIfNeeded:(BOOL)create
                                      sortedBy:(JSBFSDirectorySort)sortedBy
                                         error:(NSError**)errorPtr;
{
    // check if the URL is valid
    NSError* error = nil;
    JSBFSDoubleBool* check = [NSFileCoordinator JSBFS_fileExistsAndIsDirectoryAtURL:url error:&error];
    BOOL isExisting = [check value1];
    BOOL isDirectory = [check value2];

    if (error) {
        // if we got an error, bail
        if (errorPtr != NULL) { *errorPtr = error; }
        return nil;
    } else if (isExisting == NO && create == YES) {
        // if the file doesn't exist, and the developer wants us to create it, we need to do that
        [NSFileCoordinator JSBFS_createDirectoryAtURL:url error:&error];
    } else if (isExisting == NO && create == NO) {
        // if the file doesn't exist and the developer does not want us to create it we need to fail
        error = [[NSError alloc] initWithDomain:@"" code:0 userInfo:nil];
    } else if (isExisting == YES && isDirectory == NO) {
        // if the file exists but is not a directory, we can't continue, this class only loads directories
        error = [[NSError alloc] initWithDomain:@"" code:0 userInfo:nil];
    }
    // one last error check before initializing
    if (error) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return nil;
    }
    // initialize as normal
    self = [super initThrowWhenNil];
    self->_sortedBy = sortedBy;
    self->_url = url;
    return self;
}

// MARK: Basic API

- (BOOL)deleteFileAtIndex:(NSInteger)index error:(NSError**)errorPtr;
{
    NSError* error = nil;
    NSURL* url = [self urlAtIndex:index error:&error];
    if (error || !url) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return NO;
    }
    BOOL success = [NSFileCoordinator JSBFS_recursivelyDeleteDirectoryOrFileAtURL:url error:&error];
    if (error || !success) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return NO;
    }
    return YES;
}

- (NSInteger)contentsCount:(NSError**)errorPtr;
{
    return [NSFileCoordinator JSBFS_fileCountInDirectoryURL:[self url] error:errorPtr];
}

- (NSInteger)indexOfItemWithURL:(NSURL* _Nonnull)rhs error:(NSError*_Nullable*)errorPtr;
{
    NSError* error = nil;
    NSInteger index = NSNotFound;
    NSArray<JSBFSFileComparison*>* comparisons =
    [NSFileCoordinator JSBFS_urlComparisonsForFilesInDirectoryURL:[self url]
                                                         sortedBy:[self sortedBy]
                                                            error:&error];
    index = [comparisons indexOfObjectPassingTest:
             ^BOOL(JSBFSFileComparison* lhs, NSUInteger idx, BOOL* stop) { return [[lhs fileURL] isEqual:rhs]; }];
    
    if (index == NSNotFound && !error) {
        error = [[NSError alloc] initWithDomain:@"JSBFilesystem" code:1 userInfo:nil];
    }
    if (error) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return NSNotFound;
    }
    return index;
}

// MARK: URL Api

- (NSURL*)urlAtIndex:(NSInteger)index error:(NSError**)errorPtr;
{
    NSError* error = nil;
    NSArray<JSBFSFileComparison*>* contents =
    [NSFileCoordinator JSBFS_urlComparisonsForFilesInDirectoryURL:[self url]
                                                         sortedBy:[self sortedBy]
                                                            error:&error];
    if (error) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return nil;
    }
    return [[contents objectAtIndex:index] fileURL];
}

// MARK: Data API - Read and Write Data

- (NSData*)dataAtIndex:(NSInteger)index error:(NSError**)errorPtr;
{
    NSError* error = nil;
    NSURL* url = [self urlAtIndex:index error:&error];
    if (error) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return nil;
    }
    NSData* data = [NSFileCoordinator JSBFS_readDataFromURL:url error:&error];
    if (error) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return nil;
    }
    return data;
}

- (NSURL*)replaceItemAtIndex:(NSInteger)index withData:(NSData*)data error:(NSError**)errorPtr;
{
    NSError* error = nil;
    NSURL* url = [self urlAtIndex:index error:&error];
    if (error || !url) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return nil;
    }
    BOOL success = [NSFileCoordinator JSBFS_writeData:data toURL:url error:&error];
    if (error || !success) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return nil;
    }
    return url;
}

- (NSURL*)createFileNamed:(NSString*)fileName withData:(NSData*)data error:(NSError**)errorPtr;
{
    NSError* error = nil;
    NSURL* url = [[self url] URLByAppendingPathComponent:fileName];
    BOOL success = [NSFileCoordinator JSBFS_writeData:data toURL:url error:&error];
    if (error || !success) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return nil;
    }
    return url;
}

// MARK: File Wrapper API - Read and Write File Wrappers

- (NSFileWrapper*)fileWrapperAtIndex:(NSInteger)index error:(NSError**)errorPtr;
{
    NSError* error = nil;
    NSURL* url = [self urlAtIndex:index error:&error];
    if (error) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return nil;
    }
    NSFileWrapper *fileWrapper = [NSFileCoordinator JSBFS_readFileWrapperFromURL:url error:&error];
    if (error || !fileWrapper) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return nil;
    }
    return fileWrapper;
}

- (NSURL*)replaceItemAtIndex:(NSInteger)index withFileWrapper:(NSFileWrapper*)fileWrapper error:(NSError**)errorPtr;
{
    NSError* error = nil;
    NSURL* url = [self urlAtIndex:index error:&error];
    if (error) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return nil;
    }
    BOOL success = [NSFileCoordinator JSBFS_writeFileWrapper:fileWrapper toURL:url error:&error];
    if (error || !success) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return nil;
    }
    return url;
}

- (NSURL* _Nullable)createFileNamed:(NSString*)fileName withFileWrapper:(NSFileWrapper*)fileWrapper error:(NSError**)errorPtr;
{

    NSError* error = nil;
    NSURL* url = [[self url] URLByAppendingPathComponent:fileName];
    BOOL success = [NSFileCoordinator JSBFS_writeFileWrapper:fileWrapper toURL:url error:&error];
    if (error || !success) {
        if (errorPtr != NULL) { *errorPtr = error; }
        return nil;
    }
    return url;
}

@end
