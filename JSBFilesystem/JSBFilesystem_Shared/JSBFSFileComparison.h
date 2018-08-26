//
//  JSBFSFileComparison.h
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 27/07/2018.
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

@import IGListKit;

/*!
 * @discussion An object that represents a file on disk and a modification date.
 *             The object is intended to be Diff'ed with IGListKit
 * @discussion This object preserves value semantics.
 */
@interface JSBFSFileComparison: NSObject
@property (readonly, nonatomic, strong) NSURL*_Nonnull fileURL;
@property (readonly, nonatomic, strong) NSDate*_Nonnull modificationDate;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype _Nonnull)initWithFileURL:(NSURL*_Nonnull)fileURL
                        modificationDate:(NSDate* _Nonnull)modificationDate
NS_DESIGNATED_INITIALIZER;
/*!
 * @discussion Custom isEqual implementation that does 4 checks. The first failure
 *             encountered causes a NO return and the remaining checks are abandoned.
 * @discussion 1) Pointer Equality, 2) Class Check, 3) NSURL isEqual check,
 *             4) NSDate isEqualToDate check
 * @return Returns YES/NO.
 */
- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;
- (NSString*)description;
@end

@interface JSBFSFileComparison (IGListKit) <IGListDiffable>
/*!
 * @discussion Called by IGListKit. Do not call manually.
 * @return The NSURL object stored in fileURL.
 */
- (id)diffIdentifier;
/*!
 * @discussion Called by IGListKit. Do not call manually.
 * @return Returns YES/NO by calling -isEqual
 */
- (BOOL)isEqualToDiffableObject:(id)object;
@end
