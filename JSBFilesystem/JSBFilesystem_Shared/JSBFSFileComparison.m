//
//  JSBFileComparison.m
//  JSBFilesystem
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
    }
    return self;
}
- (id<NSObject>)diffIdentifier;
{
    return [self fileURL];
}
- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object;
{
    JSBFSFileComparison* lhs = self;
    JSBFSFileComparison* rhs = (JSBFSFileComparison*)object;
    if (![rhs isKindOfClass:[JSBFSFileComparison self]]) { return NO; }
    if (![[lhs fileURL] isEqualTo:[rhs fileURL]]) { return NO; }
    if (![[lhs modificationDate] isEqualTo:[rhs modificationDate]]) { return NO; }
    return YES;
}

@end
