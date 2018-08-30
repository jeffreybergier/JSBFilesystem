//
//  JSBFSDirectory+Internal.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/29/18.
//

#import "JSBFSDirectory+Internal.h"
#import "NSFileCoordinator+Internal.h"

@implementation JSBFSDirectory (Internal)

- (NSArray<NSURL*>*_Nullable)contentsSortedAndFiltered:(NSError*_Nullable*)errorPtr;
{
    return [NSFileCoordinator JSBFS_contentsOfDirectoryAtURL:[self url]
                                                    sortedBy:[self sortedBy]
                                                  filteredBy:[self filteredBy]
                                               filePresenter:nil
                                                       error:errorPtr];
}

- (NSArray<JSBFSFileComparison*>*_Nonnull)comparableContentsSortedAndFiltered:(NSError*_Nullable*)errorPtr;
{
    return [NSFileCoordinator JSBFS_comparableContentsOfDirectoryAtURL:[self url]
                                                              sortedBy:[self sortedBy]
                                                            filteredBy:[self filteredBy]
                                                         filePresenter:nil
                                                                 error:errorPtr];
}

@end
