//
//  NSFileCoordinator_TransformMethod_BlockNil_NormOp_tests.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/31/18.
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

@interface NSFileCoordinator_TransformMethod_BlockNil_NormOp_tests : XCTestCase

@property (nonatomic, strong) NSURL* directory;
@property (nonatomic, strong) NSString* fileName;
@property (nonatomic, strong) NSData* ogData;

@end

@implementation NSFileCoordinator_TransformMethod_BlockNil_NormOp_tests

- (void)setUp {
    [self setFileName:[[NSUUID new] UUIDString]];
    [self setOgData:[[[NSUUID new] UUIDString] dataUsingEncoding:NSUTF8StringEncoding]];
    NSFileManager* fm = [NSFileManager defaultManager];
    [self setDirectory:[[[fm URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask]
                         firstObject] URLByAppendingPathComponent:[[NSUUID new] UUIDString]]];
    BOOL success = [fm createDirectoryAtURL:[self directory]
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:nil];
    XCTAssert(success);
    NSURL* fileURL = [[self directory] URLByAppendingPathComponent:[self fileName]];
    success = [[self ogData] writeToURL:fileURL atomically:YES];
    XCTAssert(success);
}

- (void)tearDown {
    BOOL success = [[NSFileManager defaultManager] removeItemAtURL:[self directory] error:nil];
    XCTAssert(success);
}

- (void)testNSFCTransformDataReturnNILBlock;
{
    NSURL* fileURL = [[self directory] URLByAppendingPathComponent:[self fileName]];
    XCTAssertThrowsSpecificNamed([NSFileCoordinator JSBFS_readAndWriteDataAtURL:fileURL
                                                     afterTransformingWithBlock:
                                  ^NSData*_Nonnull(NSData*_Nonnull data) { return nil; }
                                                                  filePresenter:nil
                                                                          error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
}

- (void)testNSFCTransformFileWrapperReturnNILBlock;
{
    NSURL* fileURL = [[self directory] URLByAppendingPathComponent:[self fileName]];
    XCTAssertThrowsSpecificNamed([NSFileCoordinator JSBFS_readAndWriteFileWrapperAtURL:fileURL
                                                            afterTransformingWithBlock:
                                  ^NSFileWrapper*_Nonnull(NSFileWrapper*_Nonnull data) { return nil; }
                                                                         filePresenter:nil
                                                                                 error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
}

@end
