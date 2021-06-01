//
//  CPOLib.h
//  CopyPasteObserver
//
//  Created by uchiyama_Macmini on 2018/04/19.
//  Copyright © 2018年 uchiyama_Macmini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectInfo.h"

@interface CPOLib : NSObject
+ (BOOL)isExistString:(NSString*)str searchStr:(NSString*)searchStr;
+ (ObjectInfo*)getObjectInfoFromJSONstr:(NSString*) str;
+ (NSArray*)getObjectInfosFromJSONstr:(NSString*) str;
@end
