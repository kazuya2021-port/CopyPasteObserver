//
//  ObjectInfoController.h
//  CopyPasteObserver
//
//  Created by uchiyama_Macmini on 2018/04/20.
//  Copyright © 2018年 uchiyama_Macmini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectInfo.h"
@interface ObjectInfoController : NSObject
{
    NSUndoManager* undoManager;
    NSMutableArray* objInfos;
}
@property (nonatomic, copy) NSMutableArray* objInfos;
- (ObjectInfo*)getObjectIonfoFromNote:(NSString*)note;
- (void)setIsAka:(NSString*)note isAka:(BOOL)isA;
- (void)setIsAkaFalse;
- (void)addObjectInfo:(ObjectInfo*)info;
- (void)addObjectInfos:(NSArray*)ar;
- (void)removeObjectInfo:(ObjectInfo*)info;
- (void)removeObjectInfos:(NSArray*)ar;
- (void)undo;
- (void)redo;
@end
