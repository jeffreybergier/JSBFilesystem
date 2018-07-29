//
//  JSBFileComparison.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 27/07/2018.
//

@import Foundation;
@import IGListKit;

@interface JSBFSFileComparison: NSObject <IGListDiffable>
@property (readonly, nonatomic, strong) NSURL* _Nonnull fileURL;
@property (readonly, nonatomic, strong) NSDate* _Nonnull modificationDate;
- (instancetype _Nonnull)initWithFileURL:(NSURL* _Nonnull)fileURL modificationDate:(NSDate* _Nonnull)modificationDate;
- (id<NSObject> _Nonnull)diffIdentifier;
- (BOOL)isEqualToDiffableObject:(id<IGListDiffable> _Nullable)object;
@end
