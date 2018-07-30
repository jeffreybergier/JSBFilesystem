//
//  JSBFSFileComparison.m
//  JSBFSFileComparison
//
//  Created by Jeffrey Bergier on 27/07/2018.
//

#import "JSBFSFileComparison.h"

@implementation JSBFSFileComparison

- (instancetype)initWithFileURL:(NSURL*)fileURL modificationDate:(NSDate*)modificationDate;
{
    if (self = [super init]) {
        _fileURL = fileURL;
        _modificationDate = modificationDate;
        return self;
    } else {
        @throw [[NSException alloc] initWithName:NSMallocException reason:@"INIT Failed" userInfo:nil];
    }
}
- (id)diffIdentifier;
{
    return [[self fileURL] path];
}
- (BOOL)isEqualToDiffableObject:(id)object;
{
    return [self isEqual:object];
}
- (BOOL)isEqual:(id)object;
{
    JSBFSFileComparison* lhs = self;
    JSBFSFileComparison* rhs = (JSBFSFileComparison*)object;
    // if the pointers match then we're the same
    if (lhs == rhs) {
        return YES;
    }
    // if the other object is not the same kind of object, we fail
    if (![rhs isKindOfClass:[JSBFSFileComparison self]]) {
        return NO;
    }
    // if the paths don't match in the URL's then we fail
    if (![[[lhs fileURL] path] isEqualToString:[[rhs fileURL] path]]) {
        return NO;
    }
    // if the dates do not match, we fail
    if (![[lhs modificationDate] isEqualToDate:[rhs modificationDate]]) {
        return NO;
    }
    // if we made it this far, we pass
    return YES;
}

#define NSUINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define NSUINTROTATE(val, howmuch) ((((NSUInteger)val) << howmuch) | (((NSUInteger)val) >> (NSUINT_BIT - howmuch)))
- (NSUInteger)hash
{
    return NSUINTROTATE([[[self fileURL] path] hash], NSUINT_BIT / 2) ^ [[self modificationDate] hash];
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"%@, url: %@, date: %@", [super description], [[self fileURL] lastPathComponent], [self modificationDate]];
}

@end
