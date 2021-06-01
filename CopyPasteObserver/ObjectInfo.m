//
//  ObjectInfo.m
//  CopyPasteObserver
//
//  Created by uchiyama_Macmini on 2018/04/19.
//  Copyright © 2018年 uchiyama_Macmini. All rights reserved.
//

#import "ObjectInfo.h"

@implementation ObjectInfo
- (NSString *)description {
    return [NSString stringWithFormat: @"note=%@ position=[%@,%@] content=%@", _note, _position[0], _position[1], _contents];
}
@end
