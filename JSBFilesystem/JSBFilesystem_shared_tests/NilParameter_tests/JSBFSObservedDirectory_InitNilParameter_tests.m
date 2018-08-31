//
//  JSBFSObservedDirectory_InitNilParameter_tests.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/28/18.
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

@import XCTest;
@import JSBFilesystem;

@interface JSBFSObservedDirectory_InitNilParameter_tests : XCTestCase

@property (nonatomic, strong) NSURL* nonNilURL;
@property (nonatomic, strong) NSString* nonNilString;
@property (nonatomic, strong) NSArray* emptyArray;

@end

@implementation JSBFSObservedDirectory_InitNilParameter_tests

- (void)setUp {
    [self setNonNilURL:[NSURL URLWithString:@"https://www.apple.com"]];
    [self setNonNilString:@"aString"];
    [self setEmptyArray:[NSArray new]];
}

- (void)testJSBFSDirURLInitNilParameters;
{
    XCTAssertThrowsSpecificNamed([[JSBFSObservedDirectory alloc] initWithDirectoryURL:[self nonNilURL]
                                                                       createIfNeeded:NO
                                                                             sortedBy:0
                                                                           filteredBy:nil
                                                                           changeKind:JSBFSObservedDirectoryChangeKindIncludingModifications - 1
                                                                                error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertThrowsSpecificNamed([[JSBFSObservedDirectory alloc] initWithDirectoryURL:[self nonNilURL]
                                                                       createIfNeeded:NO
                                                                             sortedBy:0
                                                                           filteredBy:nil
                                                                           changeKind:JSBFSObservedDirectoryChangeKindModificationsAsInsertionsDeletions + 1
                                                                                error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertNoThrowSpecificNamed([[JSBFSObservedDirectory alloc] initWithDirectoryURL:[self nonNilURL]
                                                                        createIfNeeded:NO
                                                                              sortedBy:0
                                                                            filteredBy:nil
                                                                            changeKind:JSBFSObservedDirectoryChangeKindIncludingModifications
                                                                                 error:nil],
                                  NSException,
                                  @"");
    XCTAssertNoThrowSpecificNamed([[JSBFSObservedDirectory alloc] initWithDirectoryURL:[self nonNilURL]
                                                                        createIfNeeded:NO
                                                                              sortedBy:0
                                                                            filteredBy:nil
                                                                            changeKind:JSBFSObservedDirectoryChangeKindModificationsAsInsertionsDeletions
                                                                                 error:nil],
                                  NSException,
                                  @"");
}

- (void)testJSBFSDirBaseInitNilParameters;
{
    XCTAssertThrowsSpecificNamed([[JSBFSObservedDirectory alloc] initWithBase:1
                                                       appendingPathComponent:[self nonNilString]
                                                               createIfNeeded:NO
                                                                     sortedBy:0
                                                                   filteredBy:nil
                                                                   changeKind:JSBFSObservedDirectoryChangeKindIncludingModifications - 1
                                                                        error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertThrowsSpecificNamed([[JSBFSObservedDirectory alloc] initWithBase:1
                                                       appendingPathComponent:[self nonNilString]
                                                               createIfNeeded:NO
                                                                     sortedBy:0
                                                                   filteredBy:nil
                                                                   changeKind:JSBFSObservedDirectoryChangeKindModificationsAsInsertionsDeletions + 1
                                                                        error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertNoThrowSpecificNamed([[JSBFSObservedDirectory alloc] initWithBase:1
                                                        appendingPathComponent:[self nonNilString]
                                                                createIfNeeded:NO
                                                                      sortedBy:0
                                                                    filteredBy:nil
                                                                    changeKind:JSBFSObservedDirectoryChangeKindIncludingModifications
                                                                         error:nil],
                                  NSException,
                                  @"");
    XCTAssertNoThrowSpecificNamed([[JSBFSObservedDirectory alloc] initWithBase:1
                                                        appendingPathComponent:[self nonNilString]
                                                                createIfNeeded:NO
                                                                      sortedBy:0
                                                                    filteredBy:nil
                                                                    changeKind:JSBFSObservedDirectoryChangeKindModificationsAsInsertionsDeletions
                                                                         error:nil],
                                  NSException,
                                  @"");
}

@end
