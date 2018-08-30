//
//  JSBFSDirectory+Internal.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/29/18.
//

#import "JSBFSDirectory.h"

@interface JSBFSDirectory (Internal)

- (NSArray<NSURL*>*_Nullable)sortedAndFilteredContents:(NSError*_Nullable*)errorPtr;
- (NSArray<JSBFSFileComparison*>*_Nonnull)sortedAndFilteredComparisons:(NSError*_Nullable*)errorPtr;

@end

