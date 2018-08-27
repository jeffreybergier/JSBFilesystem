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
    JSBFSErrorCodeOperationFailedButNoCocoaErrorThrown
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

@end
