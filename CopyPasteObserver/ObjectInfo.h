//
//  ObjectInfo.h
//  CopyPasteObserver
//
//  Created by uchiyama_Macmini on 2018/04/19.
//  Copyright © 2018年 uchiyama_Macmini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectInfo : NSObject
@property (assign) BOOL isAka;
@property (nonatomic, copy) NSString* note;
@property (nonatomic, copy) NSArray* position;
@property (nonatomic, copy) NSString* contents;
@end
