//
//  SmallTypes.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/26/18.
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

#import "SmallTypes.h"

@implementation JSBFSDoubleBool
@synthesize value1 = _value1, value2 = _value2;
- (instancetype)initWithValue1:(BOOL)value1 value2:(BOOL)value2;
{
    self = [super init];
    NSParameterAssert(self);
    self->_value1 = value1;
    self->_value2 = value2;
    return self;
}
@end

@implementation JSBFSDirectorySortConverter
+ (JSBFSDirectorySort)defaultSort;
{
    return JSBFSDirectorySortNameAFirst;
}
+ (NSURLResourceKey)resourceKeyForSort:(JSBFSDirectorySort)sort;
{
    switch (sort) {
        case JSBFSDirectorySortNameAFirst:
        case JSBFSDirectorySortNameZFirst:
            return NSURLLocalizedNameKey;

        case JSBFSDirectorySortCreationNewestFirst:
        case JSBFSDirectorySortCreationOldestFirst:
            return NSURLCreationDateKey;

        case JSBFSDirectorySortModificationNewestFirst:
        case JSBFSDirectorySortModificationOldestFirst:
            return NSURLContentModificationDateKey;
    }
}

+ (BOOL)orderedAscendingForSort:(JSBFSDirectorySort)sort;
{
    switch (sort) {
        case JSBFSDirectorySortNameAFirst:
        case JSBFSDirectorySortCreationOldestFirst:
        case JSBFSDirectorySortModificationOldestFirst:
            return YES;
        case JSBFSDirectorySortNameZFirst:
        case JSBFSDirectorySortCreationNewestFirst:
        case JSBFSDirectorySortModificationNewestFirst:
            return NO;
    }
}
@end
