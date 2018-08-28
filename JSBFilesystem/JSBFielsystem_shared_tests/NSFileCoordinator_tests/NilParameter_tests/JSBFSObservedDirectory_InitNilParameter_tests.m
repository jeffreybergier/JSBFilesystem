//
//  JSBFSObservedDirectory_InitNilParameter_tests.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/28/18.
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
