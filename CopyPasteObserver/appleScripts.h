//
//  appleScripts.h
//  CopyPasteObserver
//
//  Created by uchiyama_Macmini on 2018/04/19.
//  Copyright © 2018年 uchiyama_Macmini. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "CPOLib.h"
#define RESPATH    [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Resources"]
@interface appleScripts : NSObject

- (BOOL)checkIsTouchObject;
- (void)executeCopy;
- (void)executePaste;
- (void)executeUndo;
- (void)executeAka:(NSColor*)color objID:(NSString*)objID;
- (ObjectInfo*)getObjectInfo;
- (NSArray*)getAllObjectInfo;
- (NSArray*)getAllContentsInfo;
- (void)setAllObjectNote;
- (void)deleteAllAka;
- (BOOL)checkOpened;
- (void)saveAI;
- (void)addNote:(NSString*)str;
- (void)delay:(int)wait;
@end
