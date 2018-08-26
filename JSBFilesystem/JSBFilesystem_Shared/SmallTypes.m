//
//  SmallTypes.m
//  JSBFilesystem
//
//  Created by Jeffrey Bergier on 8/26/18.
//

#import "SmallTypes.h"


@implementation JSBFSDoubleBool
- (instancetype)initWithValue1:(BOOL)value1 value2:(BOOL)value2;
{
    self = [super init];
    NSParameterAssert(self);
    self->_value1 = value1;
    self->_value2 = value2;
    return self;
}
@end
