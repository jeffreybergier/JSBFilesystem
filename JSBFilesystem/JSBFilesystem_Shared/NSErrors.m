//
//  NSErrors.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/26/18.
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

#import "NSErrors.h"

@implementation NSError (JSBFS)
+ (instancetype _Nonnull)JSBFS_operationFailedButNoCocoaErrorThrown
{
    return [[NSError alloc] initWithDomain:kJSBFSErrorDomain code:JSBFSErrorCodeOperationFailedButNoCocoaErrorThrown userInfo:nil];
}
@end

@implementation NSException (JSBFS)
+ (instancetype _Nonnull)JSBFS_arrayMapFailedInputCountDoesNotMatchOutputCount;
{
    return [[NSException alloc] initWithName:NSInternalInconsistencyException
                                      reason:@"Array Map Failed: Input Count and Output Count Mismatch."
                                    userInfo:nil];
}
+ (instancetype _Nonnull)JSBFS_unsupportedURLResourceKey;
{
    return [[NSException alloc] initWithName:NSInvalidArgumentException
                                      reason:@"Unsupported NSURLResourceKey specified. Only NSURLLocalizedNameKey, NSURLContentModificationDateKey, NSURLCreationDateKey are supported."
                                    userInfo:nil];
}
@end
