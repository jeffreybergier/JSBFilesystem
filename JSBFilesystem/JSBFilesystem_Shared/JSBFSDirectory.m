//
//  JSBFSUnobservedDirectory.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 30/07/2018.
//

#import "JSBFSDirectory.h"
#import "NSFileCoordinator+JSBFS.h"
#import "SmallCategories.h"

@implementation JSBFSDirectory

- (instancetype)initWithDirectoryURL:(NSURL*)url
                      createIfNeeded:(BOOL)create
                 sortedByResourceKey:(NSURLResourceKey)resourceKey
                    orderedAscending:(BOOL)ascending
                               error:(NSError**)errorPtr;
{
    // check if the URL is valid
    NSError* error = nil;
    JSBFSDoubleBool* check = [NSFileCoordinator JSBFS_fileExistsAndIsDirectoryAtURL:url error:&error];
    BOOL isExisting = [check value1];
    BOOL isDirectory = [check value2];

    if (error) {
        // if we got an error, bail
        *errorPtr = error;
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
        *errorPtr = error;
        return nil;
    }
    // initialize as normal
    self = [super initThrowWhenNil];
    self->_orderedAscending = ascending;
    self->_sortedBy = resourceKey;
    self->_url = url;
    return self;
}

- (NSInteger)contentsCount:(NSError**)errorPtr;
{
    return [NSFileCoordinator JSBFS_fileCountInDirectoryURL:[self url] error:errorPtr];
}
- (NSURL*)urlAtIndex:(NSInteger)index error:(NSError**)errorPtr;
{
    NSError* error = nil;
    NSArray<JSBFSFileComparison*>* contents = [NSFileCoordinator JSBFS_urlComparisonsForFilesInDirectoryURL:[self url]
                                                                  sortedByResourceKey:[self sortedBy]
                                                                     orderedAscending:[self orderedAscending]
                                                                                error:&error];
    if (error) {
        *errorPtr = error;
        return nil;
    }
    return [[contents objectAtIndex:index] fileURL];
}
- (NSData*)dataAtIndex:(NSInteger)index error:(NSError**)errorPtr;
{
    NSError* error = nil;
    NSURL* url = [self urlAtIndex:index error:&error];
    if (error) {
        *errorPtr = error;
        return nil;
    }
    NSData* data = [NSFileCoordinator JSBFS_readDataFromURL:url error:&error];
    if (error) {
        *errorPtr = error;
        return nil;
    }
    return data;
}

@end
