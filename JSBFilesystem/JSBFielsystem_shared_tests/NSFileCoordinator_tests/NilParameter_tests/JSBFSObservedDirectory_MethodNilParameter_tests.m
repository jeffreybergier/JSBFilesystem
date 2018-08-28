//
//  JSBFSObservedDirectory_MethodNilParameter_tests.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/28/18.
//

#import "JSBFSDirectory_MethodNilParameter_tests.h"

@interface JSBFSObservedDirectory_MethodNilParameter_tests : JSBFSDirectory_MethodNilParameter_tests

@end

@implementation JSBFSObservedDirectory_MethodNilParameter_tests

- (void)setUp {
    [self setDirectory:[[JSBFSObservedDirectory alloc] initWithBase:NSCachesDirectory
                                             appendingPathComponent:[[NSUUID new] UUIDString]
                                                     createIfNeeded:YES
                                                           sortedBy:0
                                                         filteredBy:nil
                                                         changeKind:JSBFSObservedDirectoryChangeKindIncludingModifications
                                                              error:nil]];
    [self setTemporaryLocation:[[self directory] url]];
    [self setValidRemoteURL:[NSURL URLWithString:@"https://www.apple.com"]];
    XCTAssertNotNil([self validRemoteURL]);
    XCTAssertNotNil([self temporaryLocation]);
    XCTAssertNotNil([self directory]);
}

@end
