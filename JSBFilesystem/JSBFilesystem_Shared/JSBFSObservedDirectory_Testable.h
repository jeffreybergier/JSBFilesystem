//
//  JSBFSDirectoryObserver_Testable.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 30/07/2018.
//

#import "NSFileCoordinator+JSBFS.h"
#import "JSBFSObservedDirectory.h"
#import "JSBFSDirectoryChanges.h"

@interface JSBFSDirectoryChanges_Testable: JSBFSDirectoryChanges
@property (readonly, nonatomic, strong) NSIndexSet* _Nonnull updates;
@end

@interface JSBFSObservedDirectory_Testable: JSBFSObservedDirectory
@end

