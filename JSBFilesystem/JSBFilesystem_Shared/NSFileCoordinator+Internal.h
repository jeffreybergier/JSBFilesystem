//
//  NSFileCoordinator+Internal.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/30/18.
//

@import Foundation;
#import "SmallTypes.h"
@class JSBFSFileComparison;
typedef NS_ENUM(NSInteger, JSBFSDirectorySort);

@interface NSFileCoordinator (Internal)

/*!
 * @discussion Read the contents of a directory.
 * @param url Directory to read from
 * @param sortedBy Desired sort order of contents
 * @param filters Optional Array of blocks to filter items out of the
 *        returned contents.
 * @param filePresenter Optional NSFilePresenter object. This will be passed to
 *        the NSFileCoordinator so that this File Presenter should not recieve
 *        requests to save the file before it can be read.
 * @param errorPtr Error parameter. Will always be populated if return is NIL.
 * @return NSArray<NSURL> or NIL.
 */
+ (NSArray<NSURL*>*_Nullable)JSBFS_contentsOfDirectoryAtURL:(NSURL*_Nonnull)url
                                                   sortedBy:(JSBFSDirectorySort)sortedBy
                                                 filteredBy:(NSArray<JSBFSDirectoryFilterBlock>*_Nullable)filters
                                              filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                                                      error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_contentsOfDirectory(at:sortedBy:filteredBy:filePresenter:));

/*!
 * @discussion Read the contents of a directory and convert them to JSBFSFileComparison objects.
 * @param url Directory to read from
 * @param sortedBy Desired sort order of contents
 * @param filters Optional Array of blocks to filter items out of the
 *        returned contents.
 * @param filePresenter Optional NSFilePresenter object. This will be passed to
 *        the NSFileCoordinator so that this File Presenter should not recieve
 *        requests to save the file before it can be read.
 * @param errorPtr Error parameter. Will always be populated if return is NIL.
 * @return NSArray<JSBFSFileComparison> or NIL.
 */
+ (NSArray<JSBFSFileComparison*>* _Nullable)JSBFS_comparableContentsOfDirectoryAtURL:(NSURL*_Nonnull)url
                                                                            sortedBy:(JSBFSDirectorySort)sortedBy
                                                                          filteredBy:(NSArray<JSBFSDirectoryFilterBlock>*_Nullable)filters
                                                                       filePresenter:(id<NSFilePresenter>_Nullable)filePresenter
                                                                               error:(NSError*_Nullable*)errorPtr
NS_SWIFT_NAME(JSBFS_comparableContentsOfDirectory(at:sortedBy:filteredBy:filePresenter:));

@end
