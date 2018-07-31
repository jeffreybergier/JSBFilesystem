//
//  JSBFSDirectoryObserver.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 28/07/2018.
//

@import Foundation;
#import "JSBFSDirectoryChanges.h"
#import "JSBFSDirectory.h"

typedef void(^JSBFSObservedDirectoryChangeBlock)(JSBFSDirectoryChanges* _Nonnull changes);

@interface JSBFSObservedDirectory: JSBFSDirectory

/// Registers intent to be updated to filesystem changes
/// NSFilePresenters are strongly held by the system
/// You must set this to NIL when done with this object or else memory will leak
/// When this is set, the internal state is forcefully updated
/// So that subsequent changes can be correctly found
@property (nonatomic, strong) JSBFSObservedDirectoryChangeBlock _Nullable changesObserved;
@property (readonly, nonatomic) NSInteger contentsCount;
- (void)forceUpdate;
@end

