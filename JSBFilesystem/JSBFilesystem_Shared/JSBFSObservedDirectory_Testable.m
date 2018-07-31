//
//  JSBFSDirectoryObserver_Testable.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 30/07/2018.
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

#import "JSBFSObservedDirectory_Testable.h"

@interface JSBFSObservedDirectory_Testable () {
    NSArray<JSBFSFileComparison*>* _internalState;
}

@end

@implementation JSBFSObservedDirectory_Testable

- (void)forceUpdate;
{
    NSArray<JSBFSFileComparison*>* lhs = _internalState;
    NSArray<JSBFSFileComparison*>* rhs =
    [NSFileCoordinator JSBFS_urlComparisonsForFilesInDirectoryURL:[self url]
                                                         sortedBy:[self sortedBy]
                                                            error:nil];
    IGListIndexSetResult* result = IGListDiff(lhs, rhs, IGListDiffEquality);
    JSBFSDirectoryChanges_Testable* changes = [[JSBFSDirectoryChanges_Testable alloc] initWithIndexSetResult:result];

    _internalState = rhs;
    JSBFSObservedDirectoryChangeBlock block = [self changesObserved];
    if (changes && block != NULL) {
        block(changes);
    }
}

@end

@implementation JSBFSDirectoryChanges_Testable
- (instancetype _Nullable)initWithIndexSetResult:(IGListIndexSetResult* _Nonnull)r;
{
    self = [super initWithIndexSetResult:r];
    self->_updates = [r updates];
    return self;
}
@end
