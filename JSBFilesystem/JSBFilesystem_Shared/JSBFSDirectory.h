//
//  JSBFSUnobservedDirectory.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 30/07/2018.
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

#import <Foundation/Foundation.h>
#import "SmallCategories.h"
#import "NSFileCoordinator+JSBFS.h"

@interface JSBFSDirectory: NSObject

@property (readonly, nonatomic, strong) NSURL* _Nonnull url;
@property (nonatomic, strong) NSArray<JSBFSDirectoryFilterBlock>* _Nullable filteredBy;
@property (readonly, nonatomic) JSBFSDirectorySort sortedBy;

// MARK: init

- (instancetype _Nullable)initWithBase:(NSSearchPathDirectory)base
                appendingPathComponent:(NSString* _Nullable)pathComponent
                        createIfNeeded:(BOOL)create
                              sortedBy:(JSBFSDirectorySort)sortedBy
                            filteredBy:(NSArray<JSBFSDirectoryFilterBlock>* _Nullable)filters
                                 error:(NSError*_Nullable*)errorPtr;
- (instancetype _Nullable)initWithDirectoryURL:(NSURL* _Nonnull)url
                                createIfNeeded:(BOOL)create
                                      sortedBy:(JSBFSDirectorySort)sortedBy
                                    filteredBy:(NSArray<JSBFSDirectoryFilterBlock>* _Nullable)filters
                                         error:(NSError*_Nullable*)errorPtr;

// MARK: Basic API
- (BOOL)deleteFileAtIndex:(NSInteger)index error:(NSError*_Nullable*)errorPtr;
- (BOOL)deleteContents:(NSError*_Nullable*)errorPtr;
- (NSInteger)contentsCount:(NSError*_Nullable*)errorPtr __attribute__((swift_error(nonnull_error)));
- (NSArray<NSURL*>* _Nullable)sortedAndFilteredContents:(NSError*_Nullable*)errorPtr;
- (NSArray<JSBFSFileComparison*>* _Nonnull)sortedAndFilteredComparisons:(NSError*_Nullable*)errorPtr;
/// Cocoa errors possible reading files from disk. If URL not found, returns NSNotFound and populates ErrorPtr in Objc - only throws error in Swift
- (NSInteger)indexOfItemWithURL:(NSURL* _Nonnull)url error:(NSError*_Nullable*)errorPtr __attribute__((swift_error(nonnull_error)));

// MARK: URL Api
- (NSURL* _Nullable)urlAtIndex:(NSInteger)index error:(NSError*_Nullable*)errorPtr;

// MARK: Data API - Read and Write Data
- (NSData* _Nullable)dataAtIndex:(NSInteger)index error:(NSError*_Nullable*)errorPtr;
- (NSURL* _Nullable)replaceItemAtIndex:(NSInteger)index withData:(NSData* _Nonnull)data error:(NSError*_Nullable*)errorPtr;
- (NSURL* _Nullable)createFileNamed:(NSString* _Nonnull)fileName withData:(NSData* _Nonnull)data error:(NSError*_Nullable*)errorPtr;

// MARK: File Wrapper API - Read and Write File Wrappers

/// Refer to Docs for how to use File Packages and NSFileWrappers
/// https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/DocumentPackages/DocumentPackages.html#//apple_ref/doc/uid/10000123i-CH106-SW1
/// https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileWrappers/FileWrappers.html#//apple_ref/doc/uid/TP40010672-CH13-DontLinkElementID_5
- (NSFileWrapper* _Nullable)fileWrapperAtIndex:(NSInteger)index error:(NSError*_Nullable*)errorPtr;
- (NSURL* _Nullable)replaceItemAtIndex:(NSInteger)index withFileWrapper:(NSFileWrapper* _Nonnull)fileWrapper error:(NSError*_Nullable*)errorPtr;
- (NSURL* _Nullable)createFileNamed:(NSString* _Nonnull)fileName withFileWrapper:(NSFileWrapper* _Nonnull)fileWrapper error:(NSError*_Nullable*)errorPtr;


@end
