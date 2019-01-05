//
//  NSFileCoordinator+DefaultParams.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 9/1/18.
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

#import "NSFileCoordinator+DefaultParams.h"
#import "NSFileCoordinator+JSBFS.h"

@implementation NSFileCoordinator (DefaultParams)

+ (BOOL)JSBFS_writeData:(NSData*_Nonnull)data
                  toURL:(NSURL*_Nonnull)url
                  error:(NSError*_Nullable*)errorPtr;
{
    return [self JSBFS_writeData:data
                           toURL:url
                   filePresenter:nil
                           error:errorPtr];
}

+ (BOOL)JSBFS_writeFileWrapper:(NSFileWrapper*_Nonnull)fileWrapper
                         toURL:(NSURL*_Nonnull)url
                         error:(NSError*_Nullable*)errorPtr;
{
    return [self JSBFS_writeFileWrapper:fileWrapper
                                  toURL:url
                          filePresenter:nil
                                  error:errorPtr];
}

+ (NSData*_Nullable)JSBFS_readDataFromURL:(NSURL*_Nonnull)url
                                    error:(NSError*_Nullable*)errorPtr;
{
    return [self JSBFS_readDataFromURL:url filePresenter:nil error:errorPtr];
}

+ (NSFileWrapper* _Nullable)JSBFS_readFileWrapperFromURL:(NSURL* _Nonnull)url
                                                   error:(NSError* _Nullable*)errorPtr;
{
    return [self JSBFS_readFileWrapperFromURL:url filePresenter:nil error:errorPtr];
}

+ (BOOL)JSBFS_readAndWriteDataAtURL:(NSURL*_Nonnull)url
         afterTransformingWithBlock:(JSBFSDataTransformBlock NS_NOESCAPE _Nonnull)transform
                              error:(NSError*_Nullable*)errorPtr;
{
    return [self JSBFS_readAndWriteDataAtURL:url
                  afterTransformingWithBlock:transform
                               filePresenter:nil
                                       error:errorPtr];
}

+ (BOOL)JSBFS_readAndWriteFileWrapperAtURL:(NSURL*_Nonnull)url
                afterTransformingWithBlock:(JSBFSFileWrapperTransformBlock NS_NOESCAPE _Nonnull)transform
                                     error:(NSError*_Nullable*)errorPtr;
{
    return [self JSBFS_readAndWriteFileWrapperAtURL:url
                         afterTransformingWithBlock:transform
                                      filePresenter:nil
                                              error:errorPtr];
}

+ (BOOL)JSBFS_deleteURL:(NSURL*_Nonnull)url
                  error:(NSError*_Nullable*)errorPtr;
{
    return [self JSBFS_deleteURL:url filePresenter:nil error:errorPtr];
}

+ (BOOL)JSBFS_batchDeleteURLs:(NSArray<NSURL*>*_Nonnull)urls
                        error:(NSError*_Nullable*)errorPtr;
{
    return [self JSBFS_batchDeleteURLs:urls filePresenter:nil error:errorPtr];
}

+ (BOOL)JSBFS_createDirectoryAtURL:(NSURL*_Nonnull)url
                             error:(NSError*_Nullable*)errorPtr;
{
    return [self JSBFS_createDirectoryAtURL:url filePresenter:nil error:errorPtr];
}

+ (JSBFSDoubleBool*_Nullable)JSBFS_fileExistsAndIsDirectoryAtURL:(NSURL*_Nonnull)url
                                                           error:(NSError*_Nullable*)errorPtr;
{
    return [self JSBFS_fileExistsAndIsDirectoryAtURL:url filePresenter:nil error:errorPtr];
}

@end
