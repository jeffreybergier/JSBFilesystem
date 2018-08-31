//
//  NSFileCoordinator_TransformMethod_BlockNil_NormOp_tests.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/31/18.
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
                                                    afterTransformdingWithBlock:
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
                                                           afterTransformdingWithBlock:
                                  ^NSFileWrapper*_Nonnull(NSFileWrapper*_Nonnull data) { return nil; }
                                                                         filePresenter:nil
                                                                                 error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
}

@end
