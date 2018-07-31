//
//  JSBFSUnobservedDirectory.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 30/07/2018.
//

#import <Foundation/Foundation.h>

@interface JSBFSUnobservedDirectory: NSObject

@property (readonly, nonatomic, strong) NSURL* _Nonnull url;
@property (readonly, nonatomic, strong) NSURLResourceKey _Nonnull sortedBy;
@property (readonly, nonatomic) BOOL orderedAscending;
@property (readonly, nonatomic) NSInteger contentsCount;

- (instancetype _Nonnull)initWithDirectoryURL:(NSURL* _Nonnull)url
                          sortedByResourceKey:(NSURLResourceKey _Nonnull)resourceKey
                             orderedAscending:(BOOL)ascending;
- (NSURL* _Nullable)urlAtIndex:(NSInteger)index;
- (NSData* _Nullable)dataAtIndex:(NSInteger)index error:(NSError** _Nullable)errorPtr;

@end
