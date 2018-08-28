//
//  NSErrors.h
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

@import Foundation;

/*!
 * @discussion Error codes for all errors used in this library.
 * @discussion Note: Cocoa errors will usually be the errors seen while using
 *             this library.
 */
typedef NS_ENUM(NSInteger, JSBFSErrorCode) {
    JSBFSErrorCodeOperationFailedButNoCocoaErrorThrown,
    JSBFSErrorDirectoryNotFoundAndNotCreated,
    JSBFSErrorSpecifiedURLIsFileExpectedDirectory,
    JSBFSErrorItemNotFound
};

/*!
 * @discussion Error domain of all errors used in this library.
 * @discussion Note: Cocoa errors will usually be the errors seen while using
 *             this library.
 */
static NSString* kJSBFSErrorDomain = @"kJSBFSErrorDomain";

@interface NSError (JSBFS)
/*!
 * @discussion In the rare case that an NSFileManager or other error throwing
 *             method returns NO for success but does not populate the NSError**
 *             this error will be used instead of a of NIL error.
 */
+ (instancetype _Nonnull)JSBFS_operationFailedButNoCocoaErrorThrown
NS_SWIFT_NAME(JSBFS_operationFailedButNoCocoaErrorThrown());
/*!
 * @discussion Error created when you asked a JSBFSDirectory to be created at
 *             a directory that does not exist AND specified NO for createIfNeeded.
 */
+ (instancetype _Nonnull)JSBFS_directoryNotFoundAndNotCreated
NS_SWIFT_NAME(JSBFS_directoryNotFoundAndNotCreated());
/*!
 * @discussion Error created when URL specified is a file on disk and a directory
 *             was expected.
 */
+ (instancetype _Nonnull)JSBFS_specifiedURLIsFileExpectedDirectory
NS_SWIFT_NAME(JSBFS_specifiedURLIsFileExpectedDirectory());
/*!
 * @discussion Error thrown when trying to find the index of an NSURL object.
 *             This throws an error to improve how it works in Swift.
 */
+ (instancetype _Nonnull)JSBFS_itemNotFound
NS_SWIFT_NAME(JSBFS_itemNotFound());
@end

@interface NSException (JSBFS)
/*!
 * @discussion In the case the array map fails because the input and output
 *             arrays counts do not match.
 */
+ (instancetype _Nonnull)JSBFS_arrayMapFailedInputCountDoesNotMatchOutputCount
NS_SWIFT_NAME(JSBFS_arrayMapFailedInputCountDoesNotMatchOutputCount());
/*!
 * @discussion In the case an unsupported URLResourceKey is specified for sorting
 *             file contents is used.
 */
+ (instancetype _Nonnull)JSBFS_unsupportedURLResourceKey
NS_SWIFT_NAME(JSBFS_unsupportedURLResourceKey());
@end
