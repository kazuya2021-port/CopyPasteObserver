//
//  CPOLib.m
//  CopyPasteObserver
//
//  Created by uchiyama_Macmini on 2018/04/19.
//  Copyright © 2018年 uchiyama_Macmini. All rights reserved.
//

#import "CPOLib.h"


@implementation CPOLib

+ (BOOL)isExistString:(NSString*)str searchStr:(NSString*)searchStr
{
    NSRange rng = [str rangeOfString:searchStr];
    if(rng.location != NSNotFound)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (ObjectInfo*)getObjectInfoFromJSONstr:(NSString*) str
{
    if([str compare:@""] == NSOrderedSame) return  nil;
    
    ObjectInfo* entry = [[ObjectInfo alloc] init];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                    options:NSJSONReadingAllowFragments
                                                      error:nil];
    if(json)
    {
        entry.note = [json objectForKey:@"note"];
        entry.position = [json objectForKey:@"position"];
        entry.contents = [json objectForKey:@"contents"];
    }
    return entry;
}

+ (NSArray*)getObjectInfosFromJSONstr:(NSString*) str
{
    NSMutableArray* objInfo = [NSMutableArray array];
    
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data
                                                    options:NSJSONReadingAllowFragments
                                                      error:nil];
    if(json)
    {
        for(NSDictionary* obj in json)
        {
            ObjectInfo* entry = [[ObjectInfo alloc] init];
            entry.note = [obj objectForKey:@"note"];
            entry.position = [obj objectForKey:@"position"];
            entry.contents = [obj objectForKey:@"contents"];
            [objInfo addObject:entry];
        }
    }
    return [objInfo copy];
}


@end
