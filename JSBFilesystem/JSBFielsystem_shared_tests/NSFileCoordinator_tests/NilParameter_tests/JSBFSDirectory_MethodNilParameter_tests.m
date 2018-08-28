//
//  JSBFSDirectory_MethodNilParameter_tests.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/28/18.
//

@import XCTest;
@import JSBFilesystem;

@interface JSBFSDirectory_MethodNilParameter_tests : XCTestCase

@property (nonatomic, strong) JSBFSDirectory* directory;
@property (nonatomic, strong) NSURL* temporaryLocation;


@end

@implementation JSBFSDirectory_MethodNilParameter_tests

- (void)setUp {
    [self setDirectory:[[JSBFSDirectory alloc] initWithBase:NSCachesDirectory
                                     appendingPathComponent:[[NSUUID new] UUIDString]
                                             createIfNeeded:YES
                                                   sortedBy:0
                                                 filteredBy:nil
                                                      error:nil]];
    [self setTemporaryLocation:[[self directory] url]];
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

@end
