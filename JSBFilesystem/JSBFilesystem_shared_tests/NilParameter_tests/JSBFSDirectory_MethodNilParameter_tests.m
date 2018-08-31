//
//  JSBFSDirectory_MethodNilParameter_tests.m
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
