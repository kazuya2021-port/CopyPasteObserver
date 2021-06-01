//
//  HotKey.h
//  CopyPasteObserver
//
//  Created by uchiyama_Macmini on 2018/04/18.
//  Copyright © 2018年 uchiyama_Macmini. All rights reserved.
//
#import <Carbon/Carbon.h>
#import <Cocoa/Cocoa.h>

typedef void (^HotKeyTask)(NSEvent*);

@interface HotKey : NSObject

// creates a new hotkey but does not register it
+ (instancetype)hotKeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags task:(HotKeyTask)task;

@property (nonatomic, assign, readonly) id target;
@property (nonatomic, readonly) SEL action;
@property (nonatomic, strong, readonly) id object;
@property (nonatomic, copy, readonly) HotKeyTask task;

@property (nonatomic, readonly) unsigned short keyCode;
@property (nonatomic, readonly) NSUInteger modifierFlags;

@end

@interface HotKeyCenter : NSObject
{
}
+ (instancetype)sharedHotKey;
- (HotKey*)registerHotKey:(HotKey *)hotkey;
- (HotKey*)registerHotKeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags target:(id)target action:(SEL)action object:(id)object;
- (void)unregisterHotKey:(HotKey*)hotKey;
- (void)unregisterHotKeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags;
- (NSSet *)registeredHotKeys;
@end
