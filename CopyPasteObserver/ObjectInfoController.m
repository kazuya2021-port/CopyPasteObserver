//
//  ObjectInfoController.m
//  CopyPasteObserver
//
//  Created by uchiyama_Macmini on 2018/04/20.
//  Copyright © 2018年 uchiyama_Macmini. All rights reserved.
//

#import "ObjectInfoController.h"

@implementation ObjectInfoController
@synthesize objInfos;

- (id)init
{
    NSLog(@"objCtrl init");
    self = [super init];
    if(self)
    {
        objInfos = [[NSMutableArray alloc] init];
        undoManager = [[NSUndoManager alloc] init];
    }
    return self;
}
- (void)addObjectInfo:(ObjectInfo*)info
{
    NSLog(@"objCtrl addObjectInfo");
    if(![objInfos containsObject:info])
    {
        [[undoManager prepareWithInvocationTarget:self] removeObjectInfo:info];
        [objInfos addObject:info];
    }
}

- (void)addObjectInfos:(NSArray*)ar
{
    NSLog(@"objCtrl addObjectInfos");
    NSArray* dupedArray = [[NSArray alloc] initWithArray:ar];
    [[undoManager prepareWithInvocationTarget:self] removeObjectInfos:dupedArray];
    for(id obj in dupedArray)
    {
        [objInfos addObject:obj];
    }
}

- (void)removeObjectInfo:(ObjectInfo*)info
{
    NSLog(@"objCtrl removeObjectInfo");
    if([objInfos containsObject:info])
    {
        [[undoManager prepareWithInvocationTarget:self] addObjectInfo:info];
        [objInfos removeObject:info];
    }
}

- (void)removeObjectInfos:(NSArray*)ar
{
    NSLog(@"objCtrl removeObjectInfos");
    NSArray* dupedArray = [[NSArray alloc] initWithArray:ar];
    [[undoManager prepareWithInvocationTarget:self] addObjectInfos:dupedArray];
    for(id obj in dupedArray)
    {
        [objInfos removeObject:obj];
    }
}

- (void)undo
{
    if([undoManager canUndo])
    {
        NSLog(@"undo");
        [undoManager undo];
    }
}
- (void)redo
{
    if([undoManager canRedo])
    {
        NSLog(@"redo");
        [undoManager redo];
    }
}

- (ObjectInfo*)getObjectIonfoFromNote:(NSString*)note
{
    NSLog(@"objCtrl getObjectIonfoFromNote");
    ObjectInfo* retObj = nil;
    for(ObjectInfo* obj in objInfos)
    {
        if([obj.note compare:note] == NSOrderedSame)
        {
            retObj = obj;
            break;
        }
    }
    return retObj;
}

- (void)setIsAka:(NSString*)note isAka:(BOOL)isA
{
    NSLog(@"objCtrl setIsAka");
    ObjectInfo* editObj = [self getObjectIonfoFromNote:note];
    if(editObj != nil)
    {
        [[undoManager prepareWithInvocationTarget:self] setIsAka:note isAka:!isA];
        editObj.isAka = isA;
    }
}

- (void)setIsAkaCurrent:(NSDictionary*)tblAka
{
    for(id key in [tblAka keyEnumerator])
    {
        for(ObjectInfo* obj in objInfos)
        {
            if([obj.note compare:key] == NSOrderedSame)
            {
                obj.isAka = ([tblAka[key] compare:@"YES"])? YES: NO;
                break;
            }
        }
    }
}

- (void)setIsAkaFalse
{
    NSMutableDictionary* curAka = [NSMutableDictionary dictionary];
    for(ObjectInfo* obj in objInfos)
    {
        [curAka setObject:(obj.isAka)? @"YES" : @"NO" forKey:obj.note];
    }
    [[undoManager prepareWithInvocationTarget:self] setIsAkaCurrent:curAka];
    for(ObjectInfo* obj in objInfos)
    {
        obj.isAka = NO;
    }
}
@end
