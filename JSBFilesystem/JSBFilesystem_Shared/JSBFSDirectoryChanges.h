//
//  JSBFSDirectoryChanges.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 28/07/2018.
//

@import IGListKit;

@interface JSBFSDirectoryChangesMove: NSObject

@property (readonly, nonatomic) NSInteger from;
@property (readonly, nonatomic) NSInteger to;
-(instancetype _Nonnull)initWithFromValue:(NSInteger)fromValue toValue:(NSInteger)toValue;

@end

@interface JSBFSDirectoryChanges: NSObject

@property (readonly, nonatomic, strong) NSIndexSet* _Nonnull insertions;
@property (readonly, nonatomic, strong) NSIndexSet* _Nonnull deletions;
@property (readonly, nonatomic, strong) NSArray<JSBFSDirectoryChangesMove*>* _Nonnull moves;
-(instancetype _Nonnull)initWithInsertions:(NSIndexSet* _Nonnull)insertions
                                 deletions:(NSIndexSet* _Nonnull)deletions
                                     moves:(NSArray<JSBFSDirectoryChangesMove*>* _Nonnull)moves;

@end

@interface JSBFSDirectoryChanges (IGListKit)
/// Returns NIL if there are no changes
- (instancetype _Nullable)initWithIndexSetResult:(IGListIndexSetResult* _Nonnull)result;
@end
