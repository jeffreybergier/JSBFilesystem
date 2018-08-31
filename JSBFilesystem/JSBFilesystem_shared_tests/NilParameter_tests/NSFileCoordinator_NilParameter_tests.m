//
//  NSFileCoordinator_NilParameter_tests.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/27/18.
//

@import XCTest;
@import JSBFilesystem;

@interface NSFileCoordinator_NilParameter_tests : XCTestCase

@property (nonatomic, strong) NSData* nonNilData;
@property (nonatomic, strong) NSFileWrapper* nonNilWrapper;
@property (nonatomic, strong) NSURL* nonNilURL;
@property (nonatomic, strong) NSArray* emptyArray;

@end

@implementation NSFileCoordinator_NilParameter_tests

- (void)setUp;
{
    [self setNonNilURL:[NSURL URLWithString:@"https://www.apple.com"]];
    [self setNonNilData:[@"S" dataUsingEncoding:NSUTF8StringEncoding]];
    [self setNonNilWrapper:[NSFileWrapper new]];
    [self setEmptyArray:[NSArray new]];
}

- (void)testNSFCWriteDataNilParameters;
{
    XCTAssertThrowsSpecificNamed([NSFileCoordinator JSBFS_writeData:nil
                                                              toURL:[self nonNilURL]
                                                      filePresenter:nil
                                                              error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertThrowsSpecificNamed([NSFileCoordinator JSBFS_writeData:[self nonNilData]
                                                              toURL:nil
                                                      filePresenter:nil
                                                              error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertNoThrowSpecific([NSFileCoordinator JSBFS_writeData:[self nonNilData]
                                                          toURL:[self nonNilURL]
                                                  filePresenter:nil
                                                          error:nil],
                             NSException,
                             @"");
}

- (void)testNSFCWriteFileWrapperNilParameters;
{
    XCTAssertThrowsSpecificNamed([NSFileCoordinator JSBFS_writeFileWrapper:nil
                                                                     toURL:[self nonNilURL]
                                                             filePresenter:nil
                                                                     error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertThrowsSpecificNamed([NSFileCoordinator JSBFS_writeFileWrapper:[self nonNilWrapper]
                                                                     toURL:nil
                                                             filePresenter:nil
                                                                     error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertNoThrowSpecific([NSFileCoordinator JSBFS_writeFileWrapper:[self nonNilWrapper]
                                                                 toURL:[self nonNilURL]
                                                         filePresenter:nil
                                                                 error:nil],
                             NSException,
                             @"");
}

- (void)testNSFCReadDataNilParameters;
{
    XCTAssertThrowsSpecificNamed([NSFileCoordinator JSBFS_readDataFromURL:nil
                                                            filePresenter:nil
                                                                    error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertNoThrowSpecificNamed([NSFileCoordinator JSBFS_readDataFromURL:[self nonNilURL]
                                                             filePresenter:nil
                                                                     error:nil],
                                  NSException,
                                  @"");
}

- (void)testNSFCReadFileWrapperNilParameters;
{
    XCTAssertThrowsSpecificNamed([NSFileCoordinator JSBFS_readFileWrapperFromURL:nil
                                                                   filePresenter:nil
                                                                           error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertNoThrowSpecificNamed([NSFileCoordinator JSBFS_readFileWrapperFromURL:[self nonNilURL]
                                                                    filePresenter:nil
                                                                            error:nil],
                                  NSException,
                                  @"");
}

- (void)testNSFCReadWriteTransformNilParameters;
{
    XCTAssertThrowsSpecificNamed([NSFileCoordinator JSBFS_readAndWriteDataAtURL:nil
                                                    afterTransformdingWithBlock:nil
                                                                  filePresenter:nil
                                                                          error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertNoThrowSpecificNamed([NSFileCoordinator JSBFS_readAndWriteDataAtURL:[self nonNilURL]
                                                     afterTransformdingWithBlock:
                                   ^NSData*_Nonnull(NSData*_Nonnull data) { return nil; }
                                                                   filePresenter:nil
                                                                           error:nil],
                                  NSException,
                                  @"");
    XCTAssertThrowsSpecificNamed([NSFileCoordinator JSBFS_readAndWriteFileWrapperAtURL:nil
                                                           afterTransformdingWithBlock:nil
                                                                         filePresenter:nil
                                                                                 error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertNoThrowSpecificNamed([NSFileCoordinator JSBFS_readAndWriteFileWrapperAtURL:[self nonNilURL]
                                                            afterTransformdingWithBlock:
                                   ^NSFileWrapper*_Nonnull(NSFileWrapper*_Nonnull data) { return nil; }
                                                                          filePresenter:nil
                                                                                  error:nil],
                                  NSException,
                                  @"");
}

- (void)testNSFCDeleteNilParameters;
{
    XCTAssertThrowsSpecificNamed([NSFileCoordinator JSBFS_deleteURL:nil
                                                      filePresenter:nil
                                                              error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertNoThrowSpecificNamed([NSFileCoordinator JSBFS_deleteURL:[self nonNilURL]
                                                       filePresenter:nil
                                                               error:nil],
                                  NSException,
                                  @"");
    XCTAssertNoThrowSpecificNamed([NSFileCoordinator JSBFS_batchDeleteURLs:nil
                                                             filePresenter:nil
                                                                     error:nil],
                                  NSException,
                                  @"");
    XCTAssertNoThrowSpecificNamed([NSFileCoordinator JSBFS_batchDeleteURLs:[self emptyArray]
                                                             filePresenter:nil
                                                                     error:nil],
                                  NSException,
                                  @"");
}

- (void)testNSFCCreateDirectoryNilParameters;
{
    XCTAssertThrowsSpecificNamed([NSFileCoordinator JSBFS_createDirectoryAtURL:nil
                                                                 filePresenter:nil
                                                                         error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertNoThrowSpecificNamed([NSFileCoordinator JSBFS_createDirectoryAtURL:[self nonNilURL]
                                                                  filePresenter:nil
                                                                          error:nil],
                                  NSException,
                                  @"");
}

- (void)testNSFCComparableContensOfDirectoryNilParameters;
{
    XCTAssertThrowsSpecificNamed([NSFileCoordinator JSBFS_comparableContentsOfDirectoryAtURL:nil
                                                                                    sortedBy:0
                                                                                  filteredBy:nil
                                                                               filePresenter:nil
                                                                                       error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertThrowsSpecificNamed([NSFileCoordinator JSBFS_comparableContentsOfDirectoryAtURL:[self nonNilURL]
                                                                                    sortedBy:JSBFSDirectorySortNameAFirst - 1
                                                                                  filteredBy:nil
                                                                               filePresenter:nil
                                                                                       error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertThrowsSpecificNamed([NSFileCoordinator JSBFS_comparableContentsOfDirectoryAtURL:[self nonNilURL]
                                                                                    sortedBy:JSBFSDirectorySortModificationOldestFirst + 1
                                                                                  filteredBy:nil
                                                                               filePresenter:nil
                                                                                       error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertNoThrowSpecificNamed([NSFileCoordinator JSBFS_comparableContentsOfDirectoryAtURL:[self nonNilURL]
                                                                                     sortedBy:JSBFSDirectorySortNameAFirst
                                                                                   filteredBy:nil
                                                                                filePresenter:nil
                                                                                        error:nil],
                                  NSException,
                                  @"");
    XCTAssertNoThrowSpecificNamed([NSFileCoordinator JSBFS_comparableContentsOfDirectoryAtURL:[self nonNilURL]
                                                                                     sortedBy:JSBFSDirectorySortModificationOldestFirst
                                                                                   filteredBy:nil
                                                                                filePresenter:nil
                                                                                        error:nil],
                                  NSException,
                                  @"");
    XCTAssertNoThrowSpecificNamed([NSFileCoordinator JSBFS_comparableContentsOfDirectoryAtURL:[self nonNilURL]
                                                                                     sortedBy:0
                                                                                   filteredBy:[self emptyArray]
                                                                                filePresenter:nil
                                                                                        error:nil],
                                  NSException,
                                  @"");

}

- (void)testNSFCContensOfDirectoryNilParameters;
{
    XCTAssertThrowsSpecificNamed([NSFileCoordinator JSBFS_contentsOfDirectoryAtURL:nil
                                                                          sortedBy:0
                                                                        filteredBy:nil
                                                                     filePresenter:nil
                                                                             error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertThrowsSpecificNamed([NSFileCoordinator JSBFS_contentsOfDirectoryAtURL:[self nonNilURL]
                                                                          sortedBy:JSBFSDirectorySortNameAFirst - 1
                                                                        filteredBy:nil
                                                                     filePresenter:nil
                                                                             error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertThrowsSpecificNamed([NSFileCoordinator JSBFS_contentsOfDirectoryAtURL:[self nonNilURL]
                                                                          sortedBy:JSBFSDirectorySortModificationOldestFirst + 1
                                                                        filteredBy:nil
                                                                     filePresenter:nil
                                                                             error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertNoThrowSpecificNamed([NSFileCoordinator JSBFS_contentsOfDirectoryAtURL:[self nonNilURL]
                                                                           sortedBy:JSBFSDirectorySortNameAFirst
                                                                         filteredBy:nil
                                                                      filePresenter:nil
                                                                              error:nil],
                                  NSException,
                                  @"");
    XCTAssertNoThrowSpecificNamed([NSFileCoordinator JSBFS_contentsOfDirectoryAtURL:[self nonNilURL]
                                                                           sortedBy:JSBFSDirectorySortModificationOldestFirst
                                                                         filteredBy:nil
                                                                      filePresenter:nil
                                                                              error:nil],
                                  NSException,
                                  @"");
    XCTAssertNoThrowSpecificNamed([NSFileCoordinator JSBFS_contentsOfDirectoryAtURL:[self nonNilURL]
                                                                           sortedBy:0
                                                                         filteredBy:[self emptyArray]
                                                                      filePresenter:nil
                                                                              error:nil],
                                  NSException,
                                  @"");

}

- (void)testNSFCFileExistsAndIsDirectoryNilParameters;
{
    XCTAssertThrowsSpecificNamed([NSFileCoordinator JSBFS_fileExistsAndIsDirectoryAtURL:nil
                                                                          filePresenter:nil
                                                                                  error:nil],
                                 NSException,
                                 NSInternalInconsistencyException,
                                 @"");
    XCTAssertNoThrowSpecificNamed([NSFileCoordinator JSBFS_fileExistsAndIsDirectoryAtURL:[self nonNilURL]
                                                                           filePresenter:nil
                                                                                   error:nil],
                                  NSException,
                                  @"");
}

//- (void)testNSFCExecuteBlockNilParameters;
//{
//    XCTAssertThrowsSpecificNamed([NSFileCoordinator JSBFS_executeBlock:nil
//                                          whileCoordinatingAccessAtURL:[self nonNilURL]
//                                                         filePresenter:nil
//                                                                 error:nil],
//                                 NSException,
//                                 NSInternalInconsistencyException,
//                                 @"");
//    XCTAssertThrowsSpecificNamed([NSFileCoordinator JSBFS_executeBlock:^{}
//                                          whileCoordinatingAccessAtURL:nil
//                                                         filePresenter:nil
//                                                                 error:nil],
//                                 NSException,
//                                 NSInternalInconsistencyException,
//                                 @"");
//    XCTAssertNoThrowSpecificNamed([NSFileCoordinator JSBFS_executeBlock:^{}
//                                           whileCoordinatingAccessAtURL:[self nonNilURL]
//                                                          filePresenter:nil
//                                                                  error:nil],
//                                  NSException,
//                                  @"");
//}

@end
