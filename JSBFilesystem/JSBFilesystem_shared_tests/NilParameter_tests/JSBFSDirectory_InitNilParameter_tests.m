//
//  JSBFSDirectory_NilParameter_tests.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/28/18.
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
