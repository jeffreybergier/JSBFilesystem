//
//  JSBFSUnobservedDirectory.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 30/07/2018.
//

#import <Foundation/Foundation.h>

@interface JSBFSDirectory: NSObject

@property (readonly, nonatomic, strong) NSURL* _Nonnull url;
@property (readonly, nonatomic, strong) NSURLResourceKey _Nonnull sortedBy;
@property (readonly, nonatomic) BOOL orderedAscending;

- (instancetype _Nullable)initWithDirectoryURL:(NSURL* _Nonnull)url
                                createIfNeeded:(BOOL)create
                           sortedByResourceKey:(NSURLResourceKey _Nonnull)resourceKey
                              orderedAscending:(BOOL)ascending
                                         error:(NSError** _Nullable)errorPtr;
- (NSURL* _Nullable)urlAtIndex:(NSInteger)index error:(NSError** _Nullable)errorPtr;
- (NSData* _Nullable)dataAtIndex:(NSInteger)index error:(NSError** _Nullable)errorPtr;
- (NSInteger)contentsCount:(NSError** _Nullable)errorPtr
__attribute__((swift_error(nonnull_error)));

@end
