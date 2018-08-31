//
//  JSBFSDirectory_NilParameter_tests.m
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

@interface JSBFSDirectory_InitNilParameter_tests : XCTestCase

@property (nonatomic, strong) NSURL* nonNilURL;
@property (nonatomic, strong) NSString* nonNilString;
@property (nonatomic, strong) NSArray* emptyArray;

@end

@implementation JSBFSDirectory_InitNilParameter_tests

- (void)setUp {
    [self setNonNilURL:[NSURL URLWithString:@"https://www.apple.com"]];
    [self setNonNilString:@"aString"];
    [self setEmptyArray:[NSArray new]];
}

- (void)testJSBFSDirURLInitNilParameters;
{
    XCTAssertThrowsSpecificNamed([[JSBFSDirectory alloc] initWithDirectoryURL:nil
                                                               createIfNeeded:NO
                                                                     sortedBy:0
                                                                   filteredBy:nil
                                                                        error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertThrowsSpecificNamed([[JSBFSDirectory alloc] initWithDirectoryURL:[self nonNilURL]
                                                               createIfNeeded:NO
                                                                     sortedBy:JSBFSDirectorySortNameAFirst - 1
                                                                   filteredBy:nil
                                                                        error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertThrowsSpecificNamed([[JSBFSDirectory alloc] initWithDirectoryURL:[self nonNilURL]
                                                               createIfNeeded:NO
                                                                     sortedBy:JSBFSDirectorySortModificationOldestFirst + 1
                                                                   filteredBy:nil
                                                                        error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertNoThrowSpecificNamed([[JSBFSDirectory alloc] initWithDirectoryURL:[self nonNilURL]
                                                                createIfNeeded:NO
                                                                      sortedBy:JSBFSDirectorySortModificationOldestFirst
                                                                    filteredBy:nil
                                                                         error:nil],
                                  NSException,
                                  @"");
    XCTAssertNoThrowSpecificNamed([[JSBFSDirectory alloc] initWithDirectoryURL:[self nonNilURL]
                                                                createIfNeeded:NO
                                                                      sortedBy:JSBFSDirectorySortNameAFirst
                                                                    filteredBy:nil
                                                                         error:nil],
                                  NSException,
                                  @"");
    XCTAssertNoThrowSpecificNamed([[JSBFSDirectory alloc] initWithDirectoryURL:[self nonNilURL]
                                                                createIfNeeded:NO
                                                                      sortedBy:0
                                                                    filteredBy:[self emptyArray]
                                                                         error:nil],
                                  NSException,
                                  @"");
}

- (void)testJSBFSDirBaseInitNilParameters;
{
    XCTAssertThrowsSpecificNamed([[JSBFSDirectory alloc] initWithBase:0
                                               appendingPathComponent:[self nonNilString]
                                                       createIfNeeded:NO
                                                             sortedBy:0
                                                           filteredBy:nil
                                                                error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertThrowsSpecificNamed([[JSBFSDirectory alloc] initWithBase:1
                                               appendingPathComponent:[self nonNilString]
                                                       createIfNeeded:NO
                                                             sortedBy:JSBFSDirectorySortNameAFirst - 1
                                                           filteredBy:nil
                                                                error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertThrowsSpecificNamed([[JSBFSDirectory alloc] initWithBase:1
                                               appendingPathComponent:[self nonNilString]
                                                       createIfNeeded:NO
                                                             sortedBy:JSBFSDirectorySortModificationOldestFirst + 1
                                                           filteredBy:nil
                                                                error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertNoThrowSpecificNamed([[JSBFSDirectory alloc] initWithBase:1
                                                appendingPathComponent:nil
                                                        createIfNeeded:NO
                                                              sortedBy:0
                                                            filteredBy:nil
                                                                 error:nil],
                                  NSException,
                                  @"");
    XCTAssertNoThrowSpecificNamed([[JSBFSDirectory alloc] initWithBase:1
                                                appendingPathComponent:nil
                                                        createIfNeeded:NO
                                                              sortedBy:JSBFSDirectorySortModificationOldestFirst
                                                            filteredBy:nil
                                                                 error:nil],
                                  NSException,
                                  @"");
    XCTAssertNoThrowSpecificNamed([[JSBFSDirectory alloc] initWithBase:1
                                                appendingPathComponent:nil
                                                        createIfNeeded:NO
                                                              sortedBy:JSBFSDirectorySortNameAFirst
                                                            filteredBy:nil
                                                                 error:nil],
                                  NSException,
                                  @"");
    XCTAssertNoThrowSpecificNamed([[JSBFSDirectory alloc] initWithBase:1
                                                appendingPathComponent:nil
                                                        createIfNeeded:NO
                                                              sortedBy:0
                                                            filteredBy:[self emptyArray]
                                                                 error:nil],
                                  NSException,
                                  @"");
}

@end
