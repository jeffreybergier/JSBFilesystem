//
//  JSBFileComparison.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 27/07/2018.
//

@import Foundation;
@import IGListKit;

@interface JSBFSFileComparison: NSObject <IGListDiffable>
@property (readonly, nonatomic, strong) NSURL* fileURL;
@property (readonly, nonatomic, strong) NSDate* modificationDate;
- (instancetype)initWithFileURL:(NSURL*)fileURL modificationDate:(NSDate*)modificationDate;
- (nonnull id<NSObject>)diffIdentifier;
- (BOOL)isEqualToDiffableObject:(nullable id<IGListDiffable>)object;
@end
