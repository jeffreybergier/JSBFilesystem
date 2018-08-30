//
//  JSBFSDirectory+Internal.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/29/18.
//

#import "JSBFSDirectory.h"

@interface JSBFSDirectory (Internal)

- (NSArray<NSURL*>*_Nullable)contentsSortedAndFiltered:(NSError*_Nullable*)errorPtr;
- (NSArray<JSBFSFileComparison*>*_Nonnull)comparableContentsSortedAndFiltered:(NSError*_Nullable*)errorPtr;

@end

