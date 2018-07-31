//
//  JSBFSFileComparison.m
//  JSBFSFileComparison
//
//  Created by Jeffrey Bergier on 27/07/2018.
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

#import "JSBFSFileComparison.h"
#import "SmallCategories.h"

@implementation JSBFSFileComparison

- (instancetype)initWithFileURL:(NSURL*)fileURL modificationDate:(NSDate*)modificationDate;
{
    self = [super initThrowWhenNil];
    self->_fileURL = fileURL;
    self->_modificationDate = modificationDate;
    return self;
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
