//
//  JSBFSDirectoryChanges.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 28/07/2018.
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

@import IGListKit;

@class JSBFSDirectoryChangesMove;
typedef NS_ENUM(NSInteger, JSBFSObservedDirectoryChangeKind);

/*!
 * @discussion An object that represents a single 'update' or 'change'.
 *             The data contained in this update is intended to update
 *             various collection views but can be used to update an UI.
 * @discussion This object preserves value semantics.
 */
@interface JSBFSDirectoryChanges: NSObject

@property (readonly, nonatomic, strong) NSIndexSet*_Nonnull insertions;
@property (readonly, nonatomic, strong) NSIndexSet*_Nonnull deletions;
@property (readonly, nonatomic, strong) NSArray<JSBFSDirectoryChangesMove*>*_Nonnull moves;

-(instancetype)init NS_UNAVAILABLE;
-(instancetype _Nonnull)initWithInsertions:(NSIndexSet*_Nonnull)insertions
                                 deletions:(NSIndexSet*_Nonnull)deletions
                                     moves:(NSArray<JSBFSDirectoryChangesMove*>*_Nonnull)moves
NS_DESIGNATED_INITIALIZER;
- (NSString*)description;

@end

/*!
 * @discussion An object that represents a single 'update' or 'change'.
 *             The data contained in this update is intended to update
 *             various collection views but can be used to update an UI.
 * @discussion This object preserves value semantics.
 */
@interface JSBFSDirectoryChangesFull: JSBFSDirectoryChanges

@property (readonly, nonatomic, strong) NSIndexSet*_Nonnull updates;

-(instancetype)init NS_UNAVAILABLE;
-(instancetype _Nonnull)initWithInsertions:(NSIndexSet*_Nonnull)insertions
                                 deletions:(NSIndexSet*_Nonnull)deletions
                                     moves:(NSArray<JSBFSDirectoryChangesMove*>*_Nonnull)moves
NS_UNAVAILABLE;
-(instancetype _Nonnull)initWithInsertions:(NSIndexSet*_Nonnull)insertions
                                 deletions:(NSIndexSet*_Nonnull)deletions
                                     moves:(NSArray<JSBFSDirectoryChangesMove*>*_Nonnull)moves
                                   updates:(NSIndexSet*_Nonnull)updates
NS_DESIGNATED_INITIALIZER;
- (NSString*)description;

@end

/*!
 * @discussion An object that represents a single move of an item from one index
 *             to a new index.
 * @discussion This object preserves value semantics.
 */
@interface JSBFSDirectoryChangesMove: NSObject
@property (readonly, nonatomic) NSInteger from;
@property (readonly, nonatomic) NSInteger to;
-(instancetype)init NS_UNAVAILABLE;
-(instancetype _Nonnull)initWithFromValue:(NSInteger)fromValue toValue:(NSInteger)toValue
NS_DESIGNATED_INITIALIZER;
@end

@interface IGListIndexSetResult (JSBFS)
/*!
 * @discussion Converts from the IGListKit change type to JSBFilesystem change type.
 * @return If changeKind is set to JSBFSObservedDirectyChangeKindModificationsAsInsertionsDeletions
 *         then return type is JSBFSDirectoryChanges. If changeKind is set to
 *         JSBFSObservedDirectyChangeKindIncludingModifications then the return
 *         type JSBFSDirectoryChangesFull. If there are no changes in the
 *         IGListIndexSetResult (self), then NIL is returned.
 */
- (JSBFSDirectoryChanges*_Nullable)changeObjectForChangeKind:(JSBFSObservedDirectoryChangeKind)changeKind;
@end
