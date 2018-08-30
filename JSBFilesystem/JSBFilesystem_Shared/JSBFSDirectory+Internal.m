//
//  JSBFSDirectory+Internal.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/29/18.
//

#import "JSBFSDirectory+Internal.h"
#import "NSFileCoordinator+JSBFS.h"

@implementation JSBFSDirectory (Internal)

- (NSArray<NSURL*>*_Nullable)sortedAndFilteredContents:(NSError*_Nullable*)errorPtr;
{
    NSArray<NSURL*>* urls = [NSFileCoordinator JSBFS_contentsOfDirectoryAtURL:[self url]
                                                                     sortedBy:[self sortedBy]
                                                                   filteredBy:[self filteredBy]
                                                                filePresenter:nil
                                                                        error:errorPtr];
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

@end
