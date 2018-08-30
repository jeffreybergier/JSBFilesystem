//
//  JSBFSDirectory_MethodNilParameter_tests.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/28/18.
//

#import "JSBFSDirectory_MethodNilParameter_tests.h"

@implementation JSBFSDirectory_MethodNilParameter_tests

- (void)setUp {
    [self setDirectory:[[JSBFSDirectory alloc] initWithBase:NSCachesDirectory
                                     appendingPathComponent:[[NSUUID new] UUIDString]
                                             createIfNeeded:YES
                                                   sortedBy:0
                                                 filteredBy:nil
                                                      error:nil]];
    [self setTemporaryLocation:[[self directory] url]];
    [self setValidRemoteURL:[NSURL URLWithString:@"https://www.apple.com"]];
    XCTAssertNotNil([self validRemoteURL]);
    XCTAssertNotNil([self temporaryLocation]);
    XCTAssertNotNil([self directory]);
}

- (void)tearDown {
    [[NSFileManager defaultManager] removeItemAtURL:[self temporaryLocation] error:nil];
}

- (void)testJSBFSDirContentsCountNilParameters;
{
    XCTAssertNoThrowSpecificNamed([[self directory] contentsCount:nil],
                                  NSException,
                                  @"");
    NSError* error = nil;
    XCTAssertNoThrowSpecificNamed([[self directory] contentsCount:&error],
                                  NSException,
                                  @"");

}

- (void)testJSBFSDirURLAtIndexNilParameters;
{
    XCTAssertThrowsSpecificNamed([[self directory] urlAtIndex:-1 error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertThrowsSpecificNamed([[self directory] urlAtIndex:NSNotFound error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertNoThrowSpecificNamed([[self directory] urlAtIndex:0 error:nil],
                                  NSException,
                                  @"");
    NSError* error = nil;
    XCTAssertNoThrowSpecificNamed([[self directory] urlAtIndex:0 error:&error],
                                  NSException,
                                  @"");
}

- (void)testJSBFSDirDeleteContentsNilParameters;
{
    XCTAssertNoThrowSpecificNamed([[self directory] deleteContents:nil],
                                  NSException,
                                  @"");
    NSError* error = nil;
    XCTAssertNoThrowSpecificNamed([[self directory] deleteContents:&error],
                                  NSException,
                                  @"");
}

- (void)testJSBFSDirIndexOfURLNilParameters;
{
    XCTAssertThrowsSpecificNamed([[self directory] indexOfItemWithURL:nil error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    NSError* error = nil;
    XCTAssertThrowsSpecificNamed([[self directory] indexOfItemWithURL:nil error:&error],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertNoThrowSpecificNamed([[self directory] indexOfItemWithURL:[self validRemoteURL] error:nil],
                                 NSException,
                                 @"");
}

@end
