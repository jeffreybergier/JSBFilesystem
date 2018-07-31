//
//  JSBFSUnobservedDirectory.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 30/07/2018.
//

#import "JSBFSUnobservedDirectory.h"
#import "SmallCategories.h"

@implementation JSBFSUnobservedDirectory

@dynamic contentsCount;

- (instancetype _Nonnull)initWithDirectoryURL:(NSURL* _Nonnull)url
                          sortedByResourceKey:(NSURLResourceKey _Nonnull)resourceKey
                             orderedAscending:(BOOL)ascending;
{
    self = [super initThrowWhenNil];
    self->_orderedAscending = ascending;
    self->_sortedBy = resourceKey;
    self->_url = url;
    return self;
}
- (NSURL* _Nullable)urlAtIndex:(NSInteger)index;
{
    return nil;
}
- (NSData* _Nullable)dataAtIndex:(NSInteger)index error:(NSError** _Nullable)errorPtr;
{
    return nil;
}

@end
