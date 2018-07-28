//
//  NSFileCoordinator+JSBFS.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 27/07/2018.
//

#import "NSFileCoordinator+JSBFS.h"

@implementation NSFileCoordinator (JSBFS)

+ (BOOL)JSBFS_writeData:(NSData*)data toURL:(NSURL*)url error:(NSError**)errorPtr;
{
    NSError* outerError = nil;
    __block NSError* innerError = nil;
    __block BOOL innerSuccess = NO;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateWritingItemAtURL:url
                          options:NSFileCoordinatorWritingForReplacing
                            error:&outerError
                       byAccessor:^(NSURL * _Nonnull newURL)
    {
        innerSuccess = [data writeToURL:newURL options:NSDataWritingAtomic error:&innerError];
    }];
    if (outerError != NULL) {
        *errorPtr = outerError;
        return NO;
    } else if (innerError != NULL || !innerSuccess) {
        *errorPtr = innerError;
        return NO;
    } else {
        return YES;
    }
}

+ (NSData*)JSBFS_readDataFromURL:(NSURL*)url
                           error:(NSError**)errorPtr;
{
    NSError* outerError = nil;
    __block NSError* innerError = nil;
    __block NSData* data = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateReadingItemAtURL:url
                          options:NSFileCoordinatorReadingResolvesSymbolicLink
                            error:&outerError
                       byAccessor:^(NSURL * _Nonnull newURL)
    {
        data = [NSData dataWithContentsOfURL:newURL options:0 error:&innerError];
    }];
    if (outerError != NULL) {
        *errorPtr = outerError;
        return nil;
    } else if (innerError != NULL || data == nil) {
        *errorPtr = innerError;
        return nil;
    } else {
        return data;
    }
}

+ (BOOL)JSBFS_recursivelyDeleteDirectoryOrFileAtURL:(NSURL*)url
                                              error:(NSError**)errorPtr;
{
    NSError* outerError = nil;
    __block NSError* innerError = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateWritingItemAtURL:url
                          options:NSFileCoordinatorWritingForDeleting
                            error:&outerError
                       byAccessor:^(NSURL * _Nonnull newURL)
     {
         [[NSFileManager defaultManager] trashItemAtURL:newURL resultingItemURL:nil error:&innerError];
     }];
    if (outerError != NULL) {
        *errorPtr = outerError;
        return NO;
    } else if (innerError != NULL) {
        *errorPtr = innerError;
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)JSBFS_moveSourceFileURL:(NSURL*)sourceURL
           toDestinationFileURL:(NSURL*)destinationURL
                          error:(NSError**)errorPtr;
{
    NSError* outerError = nil;
    __block NSError* innerError = nil;
    __block BOOL innerSuccess = NO;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateReadingItemAtURL:sourceURL
                          options:0
                 writingItemAtURL:destinationURL
                          options:NSFileCoordinatorWritingForReplacing << NSFileCoordinatorWritingForMoving
                            error:&outerError
                       byAccessor:^(NSURL * _Nonnull newReadingURL, NSURL * _Nonnull newWritingURL)
     {
         NSFileManager* fm = [NSFileManager defaultManager];
         NSURL* parentDir = [newWritingURL URLByDeletingLastPathComponent];
         innerSuccess = [fm createDirectoryAtURL:parentDir withIntermediateDirectories:YES attributes:nil error:&innerError];
         if (!innerSuccess || innerError != nil) { return; }
         innerSuccess = [fm moveItemAtURL:newReadingURL toURL:newWritingURL error:&innerError];
     }];
    if (outerError != NULL) {
        *errorPtr = outerError;
        return NO;
    } else if (innerError != NULL || !innerSuccess) {
        *errorPtr = innerError;
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)JSBFS_createDirectoryAtURL:(NSURL* _Nonnull)url
                             error:(NSError* _Nullable*)errorPtr;
{
    NSError* outerError = nil;
    __block NSError* innerError = nil;
    __block BOOL innerSuccess = NO;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateWritingItemAtURL:url
                          options:NSFileCoordinatorWritingForReplacing
                            error:&outerError
                       byAccessor:^(NSURL * _Nonnull newURL)
     {
         innerSuccess = [[NSFileManager defaultManager] createDirectoryAtURL:newURL withIntermediateDirectories:YES attributes:nil error:&innerError];
     }];
    if (outerError != NULL) {
        *errorPtr = outerError;
        return NO;
    } else if (innerError != NULL || !innerSuccess) {
        *errorPtr = innerError;
        return NO;
    } else {
        return YES;
    }
}

+ (NSInteger)JSBFS_fileCountInDirectoryURL:(NSURL*)url
                                     error:(NSError**)errorPtr;
{

    NSError* outerError = nil;
    __block NSError* innerError = nil;
    __block NSArray<NSURL*>* contents = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateReadingItemAtURL:url
                          options:NSFileCoordinatorReadingResolvesSymbolicLink
                            error:&outerError
                       byAccessor:^(NSURL* _Nonnull newURL)
     {
         contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url
                                       includingPropertiesForKeys:nil
                                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                                            error:&innerError];
     }];
    if (outerError != NULL) {
        *errorPtr = outerError;
        return 0;
    } else if (innerError != NULL || contents == nil) {
        *errorPtr = innerError;
        return 0;
    } else {
        return [contents count];
    }
}

+ (JSBFSDoubleBool*)JSBFS_fileExistsAndIsDirectoryAtURL:(NSURL*)url error:(NSError**)errorPtr;
{
    NSError* outerError = nil;
    __block NSError* innerError = nil;
    __block JSBFSDoubleBool* value = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateReadingItemAtURL:url
                          options:NSFileCoordinatorReadingResolvesSymbolicLink
                            error:&outerError
                       byAccessor:^(NSURL* _Nonnull newURL)
     {
         BOOL isDirectory = NO;
         BOOL isExisting = [[NSFileManager defaultManager] fileExistsAtPath:[newURL path] isDirectory:&isDirectory];
         value = [[JSBFSDoubleBool alloc] initWithValue1:isExisting value2:isDirectory];
     }];
    if (outerError != NULL) {
        *errorPtr = outerError;
        return nil;
    } else if (innerError != NULL || value == nil) {
        *errorPtr = innerError;
        return nil;
    } else {
        return value;
    }
}

+ (NSArray<JSBFSFileComparison*>*)JSBFS_urlComparisonsForFilesInDirectoryURL:(NSURL* _Nonnull)url
                                                         sortedByResourceKey:(NSURLResourceKey)resourceKey
                                                            orderedAscending:(BOOL)ascending
                                                                       error:(NSError* _Nullable*)errorPtr;
{
    NSError* outerError = nil;
    __block NSError* innerError = nil;
    __block NSURL* dirURL = url;
    __block NSArray<NSURL*>* contents = nil;
    NSMutableArray<JSBFSFileComparison*>* values = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];

    // Step1: get the list of files in the Directory
    [c coordinateReadingItemAtURL:dirURL
                          options:NSFileCoordinatorReadingResolvesSymbolicLink
                            error:&outerError
                       byAccessor:^(NSURL* _Nonnull newURL)
     {

         dirURL = newURL;
         contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:newURL
                                                   includingPropertiesForKeys:nil
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                        error:&innerError];
     }];
    // check if that operation failed
    if (outerError != NULL) {
        *errorPtr = outerError;
        return nil;
    } else if (innerError != NULL || contents == nil) {
        *errorPtr = innerError;
        return nil;
    }

    // Step2: prepare the files to be read
    [c prepareForReadingItemsAtURLs:contents
                            options:NSFileCoordinatorReadingResolvesSymbolicLink
                 writingItemsAtURLs:@[]
                            options:0
                              error:&outerError
                         byAccessor:^(void (^ _Nonnull completionHandler)(void))
    {
        contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:dirURL
                                                  includingPropertiesForKeys:@[NSURLLocalizedNameKey, NSURLContentModificationDateKey, NSURLCreationDateKey]
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                       error:&innerError];
        completionHandler();
    }];
    // check if that operation failed
    if (outerError != NULL) {
        *errorPtr = outerError;
        return nil;
    } else if (innerError != NULL || contents == nil) {
        *errorPtr = innerError;
        return nil;
    }

    // Step3: Map into custom objects
    values = [[NSMutableArray alloc] initWithCapacity:[contents count]];
    for (NSURL* url in contents) {
        NSDate* modDate = nil;
        [url getResourceValue:&modDate forKey:NSURLContentModificationDateKey error:&outerError];
        if (outerError != NULL || url == nil) { break; }
        JSBFSFileComparison* value = [[JSBFSFileComparison alloc] initWithFileURL:url modificationDate:modDate];
        [values addObject:value];
    }
    if ([values count] != [contents count]) { return nil; } // something went wrong if the arrays don't match counts

    // Step4: sort according to preference
    [values sortUsingComparator:^NSComparisonResult(JSBFSFileComparison* _Nonnull lhs, JSBFSFileComparison* _Nonnull rhs) {
        if ([resourceKey isEqualToString:NSURLLocalizedNameKey]) {
            NSString* lhsName = nil;
            NSString* rhsName = nil;
            BOOL lhsSuccess = [[lhs fileURL] getResourceValue:&lhsName forKey:resourceKey error:&innerError];
            BOOL rhsSuccess = [[rhs fileURL] getResourceValue:&rhsName forKey:resourceKey error:&innerError];
            if (innerError || !lhsSuccess || !rhsSuccess || !lhsName || !rhsName) { return NSOrderedSame; }
            if (ascending) {
                return [lhsName localizedCaseInsensitiveCompare:rhsName];
            } else {
                return [rhsName localizedCaseInsensitiveCompare:lhsName];
            }
        } else if ([resourceKey isEqualToString:NSURLContentModificationDateKey] || [resourceKey isEqualToString:NSURLCreationDateKey]) {
            NSDate* lhsDate = nil;
            NSDate* rhsDate = nil;
            BOOL lhsSuccess = [[lhs fileURL] getResourceValue:&lhsDate forKey:resourceKey error:&innerError];
            BOOL rhsSuccess = [[rhs fileURL] getResourceValue:&rhsDate forKey:resourceKey error:&innerError];
            if (innerError || !lhsSuccess || !rhsSuccess || !lhsDate || !rhsDate) { return NSOrderedSame; }
            if (ascending) {
                return [lhsDate compare:rhsDate];
            } else {
                return [rhsDate compare:lhsDate];
            }
        } else {
            @throw [[NSException alloc] initWithName:@"Unsupported NSURLResourceKey" reason:@"This function only supports NSURLLocalizedNameKey, NSURLContentModificationDateKey, NSURLCreationDateKey" userInfo:nil];
        }
    }];
    // last error check
    if (outerError != NULL) {
        *errorPtr = outerError;
        return nil;
    } else if (innerError != NULL) {
        *errorPtr = innerError;
        return nil;
    } else {
        return [values copy];
    }
}

@end

@implementation JSBFSDoubleBool
- (instancetype)initWithValue1:(BOOL)value1 value2:(BOOL)value2;
{
    if (self = [super init]) {
        _value1 = value1;
        _value2 = value2;
    }
    return self;
}
@end
