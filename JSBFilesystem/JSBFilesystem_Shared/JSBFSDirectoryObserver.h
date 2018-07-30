//
//  JSBFSDirectoryObserver.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 28/07/2018.
//

@import Foundation;
#import "JSBFSDirectoryChanges.h"

typedef void(^JSBFSDirectoryObserverChangeBlock)(JSBFSDirectoryChanges* _Nonnull changes);

@interface JSBFSDirectoryObserver : NSObject

/// Registers intent to be updated to filesystem changes
/// NSFilePresenters are strongly held by the system
/// You must set this to NIL when done with this object or else memory will leak
/// When this is set, the internal state is forcefully updated
/// So that subsequent changes can be correctly found
@property (nonatomic, strong) JSBFSDirectoryObserverChangeBlock _Nullable changesObserved;
@property (readonly, nonatomic, strong) NSURL* _Nonnull observedDirectoryURL;
@property (readonly, nonatomic, strong) NSURLResourceKey _Nonnull sortedBy;
@property (readonly, nonatomic) BOOL orderedAscending;

- (instancetype _Nonnull)initWithDirectoryURL:(NSURL* _Nonnull)url
                          sortedByResourceKey:(NSURLResourceKey _Nonnull)resourceKey
                             orderedAscending:(BOOL)ascending;
- (void)forceUpdate;

@end

