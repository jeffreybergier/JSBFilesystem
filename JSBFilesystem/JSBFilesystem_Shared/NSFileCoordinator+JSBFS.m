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
    if (outerError) {
        *errorPtr = outerError;
        return NO;
    } else if (innerError || !innerSuccess) {
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
    if (outerError) {
        *errorPtr = outerError;
        return nil;
    } else if (innerError || !data) {
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
        #if TARGET_OS_IPHONE
         [[NSFileManager defaultManager] removeItemAtURL:newURL error:&innerError];
        #else
         [[NSFileManager defaultManager] trashItemAtURL:newURL resultingItemURL:nil error:&innerError];
        #endif
     }];
    if (outerError) {
        *errorPtr = outerError;
        return NO;
    } else if (innerError) {
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
    if (outerError) {
        *errorPtr = outerError;
        return NO;
    } else if (innerError || !innerSuccess) {
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
    if (outerError) {
        *errorPtr = outerError;
        return NO;
    } else if (innerError || !innerSuccess) {
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
    if (outerError) {
        *errorPtr = outerError;
        return 0;
    } else if (innerError || !contents) {
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
    if (outerError) {
        *errorPtr = outerError;
        return nil;
    } else if (innerError || !value) {
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
    NSError* error = nil;
    NSURL* updatedURL = nil;
    NSArray<NSURL*>* _contents = [self __JSBFS_step1_getFileListAtURL:url newURL:&updatedURL error:&error];
    if (error || !_contents || !updatedURL) {
        *errorPtr = error;
        return nil;
    }
    NSArray<NSURL*>* contents = [self __JSBFS_step2_coordinateFilesAtURL:updatedURL error:&error];
    if (error || !contents) {
        *errorPtr = error;
        return nil;
    }
    NSMutableArray<JSBFSFileComparison*>* unsorted = [self __JSBFS_step3_mapContents:contents error:&error];
    if (error || !unsorted) {
        *errorPtr = error;
        return nil;
    }
    NSArray<JSBFSFileComparison*>* sorted = [self __JSBFS_step4_sortContents:unsorted sortedByResourceKey:resourceKey orderedAscending:ascending error:&error];
    if (error || !sorted) {
        *errorPtr = error;
        return nil;
    }
    return sorted;
}

/// Step1: get the list of files in the Directory
+ (NSArray<NSURL*>*)__JSBFS_step1_getFileListAtURL:(NSURL*)dirURL newURL:(NSURL**)newURL error:(NSError**)errorPtr;
{
    NSError* outerError = nil;
    __block NSError* innerError = nil;
    __block NSArray<NSURL*>* contents = nil;
    __block NSURL* updatedURL = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
    [c coordinateReadingItemAtURL:dirURL
                          options:NSFileCoordinatorReadingResolvesSymbolicLink
                            error:&outerError
                       byAccessor:^(NSURL* _Nonnull newURL)
     {

         updatedURL = newURL;
         contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:newURL
                                                  includingPropertiesForKeys:nil
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                       error:&innerError];
     }];

    // check if that operation failed
    if (outerError) {
        *errorPtr = outerError;
        return nil;
    } else if (innerError || !contents || !updatedURL) {
        *errorPtr = innerError;
        return nil;
    } else {
        *newURL = updatedURL;
        return contents;
    }
}

/// Step2: prepare the files to be read
+ (NSArray<NSURL*>*)__JSBFS_step2_coordinateFilesAtURL:(NSURL*)dirURL error:(NSError**)errorPtr;
{
    NSError* outerError = nil;
    __block NSError* innerError = nil;
    __block NSArray<NSURL*>* contents = nil;
    NSFileCoordinator* c = [[NSFileCoordinator alloc] init];
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
    if (outerError) {
        *errorPtr = outerError;
        return nil;
    } else if (innerError || !contents) {
        *errorPtr = innerError;
        return nil;
    } else {
        return contents;
    }
}

/// Step3: Map into custom objects
+ (NSMutableArray<JSBFSFileComparison*>*)__JSBFS_step3_mapContents:(NSArray<NSURL*>*)contents error:(NSError**)errorPtr;
{
    NSError* error = nil;
    BOOL success = NO;
    NSMutableArray<JSBFSFileComparison*>* values = [[NSMutableArray alloc] initWithCapacity:[contents count]];
    for (NSURL* url in contents) {
        NSDate* modDate = nil;
        success = [url getResourceValue:&modDate forKey:NSURLContentModificationDateKey error:&error];
        if (error || !modDate || !success) {
            *errorPtr = error;
            break;
        }
        JSBFSFileComparison* value = [[JSBFSFileComparison alloc] initWithFileURL:url modificationDate:modDate];
        [values addObject:value];
    }
    if ([values count] != [contents count] || error || !success) {
        *errorPtr = error;
        return nil;
    } else {
        return values;
    }
}

/// Step4: sort according to preference
+ (NSArray<JSBFSFileComparison*>*)__JSBFS_step4_sortContents:(NSMutableArray<JSBFSFileComparison*>*)contents
                                                sortedByResourceKey:(NSURLResourceKey)resourceKey
                                                   orderedAscending:(BOOL)ascending
                                                              error:(NSError**)errorPtr;
{
    __block NSError* error = nil;
    __block BOOL lhsSuccess = NO;
    __block BOOL rhsSuccess = NO;
    [contents sortUsingComparator:^NSComparisonResult(JSBFSFileComparison* _Nonnull lhs, JSBFSFileComparison* _Nonnull rhs) {
        if ([resourceKey isEqualToString:NSURLLocalizedNameKey]) {
            NSString* lhsName = nil;
            NSString* rhsName = nil;
            lhsSuccess = [[lhs fileURL] getResourceValue:&lhsName forKey:resourceKey error:&error];
            rhsSuccess = [[rhs fileURL] getResourceValue:&rhsName forKey:resourceKey error:&error];
            if (error || !lhsSuccess || !rhsSuccess || !lhsName || !rhsName) { return NSOrderedSame; }
            if (ascending) {
                return [lhsName localizedCaseInsensitiveCompare:rhsName];
            } else {
                return [rhsName localizedCaseInsensitiveCompare:lhsName];
            }
        } else if ([resourceKey isEqualToString:NSURLContentModificationDateKey] || [resourceKey isEqualToString:NSURLCreationDateKey]) {
            NSDate* lhsDate = nil;
            NSDate* rhsDate = nil;
            lhsSuccess = [[lhs fileURL] getResourceValue:&lhsDate forKey:resourceKey error:&error];
            rhsSuccess = [[rhs fileURL] getResourceValue:&rhsDate forKey:resourceKey error:&error];
            if (error || !lhsSuccess || !rhsSuccess || !lhsDate || !rhsDate) { return NSOrderedSame; }
            if (ascending) {
                return [lhsDate compare:rhsDate];
            } else {
                return [rhsDate compare:lhsDate];
            }
        } else {
            @throw [[NSException alloc] initWithName:@"Unsupported NSURLResourceKey" reason:@"This function only supports NSURLLocalizedNameKey, NSURLContentModificationDateKey, NSURLCreationDateKey" userInfo:nil];
        }
    }];
    if (error || !lhsSuccess || !rhsSuccess) {
        *errorPtr = error;
        return nil;
    } else {
        return [contents copy];
    }
}

@end

@implementation JSBFSDoubleBool
- (instancetype)initWithValue1:(BOOL)value1 value2:(BOOL)value2;
{
    if (self = [super init]) {
        _value1 = value1;
        _value2 = value2;
        return self;
    } else {
        @throw [[NSException alloc] initWithName:NSMallocException reason:@"INIT Failed" userInfo:nil];
    }
}
@end
