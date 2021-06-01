//
//  HotKey.m
//  CopyPasteObserver
//
//  Created by uchiyama_Macmini on 2018/04/18.
//  Copyright © 2018年 uchiyama_Macmini. All rights reserved.
//

#import "HotKey.h"

OSStatus hotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData);

@interface HotKey ()

@property (nonatomic, retain) NSValue *hotKeyRef;
@property (nonatomic) UInt32 hotKeyID;


@property (nonatomic, assign, setter = _setTarget:) id target;
@property (nonatomic, setter = _setAction:) SEL action;
@property (nonatomic, strong, setter = _setObject:) id object;
@property (nonatomic, copy, setter = _setTask:) HotKeyTask task;

@property (nonatomic, setter = _setKeyCode:) unsigned short keyCode;
@property (nonatomic, setter = _setModifierFlags:) NSUInteger modifierFlags;

@end


@implementation HotKey

+ (instancetype)hotKeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags task:(HotKeyTask)task {
    HotKey *newHotKey = [[self alloc] init];
    [newHotKey _setTask:task];
    [newHotKey _setKeyCode:keyCode];
    [newHotKey _setModifierFlags:flags];
    return newHotKey;
}

- (void) dealloc {
    [[HotKeyCenter sharedHotKey] unregisterHotKey:self];
}

- (NSUInteger)hash {
    return [self keyCode] ^ [self modifierFlags];
}

- (BOOL)isEqual:(id)object {
    BOOL equal = NO;
    if ([object isKindOfClass:[HotKey class]]) {
        equal = ([object keyCode] == [self keyCode]);
        equal &= ([object modifierFlags] == [self modifierFlags]);
    }
    return equal;
}

- (NSString *)description {
    NSMutableArray *bits = [NSMutableArray array];
    if ((_modifierFlags & NSControlKeyMask) > 0) { [bits addObject:@"NSControlKeyMask"]; }
    if ((_modifierFlags & NSCommandKeyMask) > 0) { [bits addObject:@"NSCommandKeyMask"]; }
    if ((_modifierFlags & NSShiftKeyMask) > 0) { [bits addObject:@"NSShiftKeyMask"]; }
    if ((_modifierFlags & NSAlternateKeyMask) > 0) { [bits addObject:@"NSAlternateKeyMask"]; }
    
    NSString *flags = [NSString stringWithFormat:@"(%@)", [bits componentsJoinedByString:@" | "]];
    NSString *invokes = @"(block)";
    if ([self target] != nil && [self action] != nil) {
        invokes = [NSString stringWithFormat:@"[%@ %@]", [self target], NSStringFromSelector([self action])];
    }
    return [NSString stringWithFormat:@"%@\n\t(key: %hu\n\tflags: %@\n\tinvokes: %@)", [super description], [self keyCode], flags, invokes];
}

- (void)invokeWithEvent:(NSEvent *)event {
    if (_target != nil && _action != nil && [_target respondsToSelector:_action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_target performSelector:_action withObject:event withObject:_object];
#pragma clang diagnostic pop
    } else if (_task != nil) {
        _task(event);
    }
}
@end


static HotKeyCenter *sharedHotKey = nil;

@implementation HotKeyCenter {
    NSMutableSet *_registeredHotKeys;
    UInt32 _nextHotKeyID;
}

+ (instancetype)sharedHotKey
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHotKey = [super allocWithZone:nil];
        sharedHotKey = [sharedHotKey init];
        
        EventTypeSpec eventSpec;
        eventSpec.eventClass = kEventClassKeyboard;
        eventSpec.eventKind = kEventHotKeyReleased;
        
        InstallApplicationEventHandler(&hotKeyHandler, 1, &eventSpec, NULL, NULL);
    });
    return sharedHotKey;
}

+ (id)allocWithZone:(NSZone *)zone {
    return sharedHotKey;
}

- (id)init
{
    if (self != sharedHotKey) { return sharedHotKey; }
    
    self = [super init];
    if(self)
    {
        _registeredHotKeys = [[NSMutableSet alloc] init];
        _nextHotKeyID = 1;
    }
    return self;
}

- (NSSet *)hotKeysMatching:(BOOL(^)(HotKey *hotkey))matcher {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return matcher(evaluatedObject);
    }];
    return [_registeredHotKeys filteredSetUsingPredicate:predicate];
}

- (BOOL)hasRegisteredHotKeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags {
    return [self hotKeysMatching:^BOOL(HotKey *hotkey) {
        return hotkey.keyCode == keyCode && hotkey.modifierFlags == flags;
    }].count > 0;
}

UInt32 CarbonModifierFlagsFromCocoaModifiers(NSUInteger flags) {
    UInt32 newFlags = 0;
    if ((flags & NSControlKeyMask) > 0) { newFlags |= controlKey; }
    if ((flags & NSCommandKeyMask) > 0) { newFlags |= cmdKey; }
    if ((flags & NSShiftKeyMask) > 0) { newFlags |= shiftKey; }
    if ((flags & NSAlternateKeyMask) > 0) { newFlags |= optionKey; }
    if ((flags & NSAlphaShiftKeyMask) > 0) { newFlags |= alphaLock; }
    return newFlags;
}

- (HotKey *)_registerHotKey:(HotKey *)hotKey {
    if ([_registeredHotKeys containsObject:hotKey]) {
        return hotKey;
    }
    
    EventHotKeyID keyID;
    keyID.signature = 'htk1';
    keyID.id = _nextHotKeyID;
    
    EventHotKeyRef carbonHotKey;
    UInt32 flags = CarbonModifierFlagsFromCocoaModifiers([hotKey modifierFlags]);
    OSStatus err = RegisterEventHotKey([hotKey keyCode], flags, keyID, GetEventDispatcherTarget(), 0, &carbonHotKey);
    
    //error registering hot key
    if (err != 0) { return nil; }
    
    NSValue *refValue = [NSValue valueWithPointer:carbonHotKey];
    [hotKey setHotKeyRef:refValue];
    [hotKey setHotKeyID:_nextHotKeyID];
    
    _nextHotKeyID++;
    [_registeredHotKeys addObject:hotKey];
    
    return hotKey;
}

- (HotKey *)registerHotKey:(HotKey *)hotKey {
    return [self _registerHotKey:hotKey];
}

- (void)unregisterHotKeysMatching:(BOOL(^)(HotKey *hotkey))matcher {
    //explicitly unregister the hotkey, since relying on the unregistration in -dealloc can be problematic
    @autoreleasepool {
        NSSet *matches = [self hotKeysMatching:matcher];
        for (HotKey *hotKey in matches) {
            [self unregisterHotKey:hotKey];
        }
    }
}

- (void)unregisterHotKey:(HotKey *)hotKey {
    NSValue *hotKeyRef = [hotKey hotKeyRef];
    if (hotKeyRef) {
        EventHotKeyRef carbonHotKey = (EventHotKeyRef)[hotKeyRef pointerValue];
        UnregisterEventHotKey(carbonHotKey);
        [hotKey setHotKeyRef:nil];
    }
    
    [_registeredHotKeys removeObject:hotKey];
}

- (void)unregisterHotKeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags {
    [self unregisterHotKeysMatching:^BOOL(HotKey *hotkey) {
        return hotkey.keyCode == keyCode && hotkey.modifierFlags == flags;
    }];
}


- (HotKey *)registerHotKeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)flags target:(id)target action:(SEL)action object:(id)object {
    //we can't add a new hotkey if something already has this combo
    if ([self hasRegisteredHotKeyWithKeyCode:keyCode modifierFlags:flags]) { return NULL; }
    
    //build the hotkey object:
    HotKey *newHotKey = [[HotKey alloc] init];
    [newHotKey _setTarget:target];
    [newHotKey _setAction:action];
    [newHotKey _setObject:object];
    [newHotKey _setKeyCode:keyCode];
    [newHotKey _setModifierFlags:flags];
    return [self _registerHotKey:newHotKey];
}

- (NSSet *)registeredHotKeys {
    return [self hotKeysMatching:^BOOL(HotKey *hotkey) {
        return hotkey.hotKeyRef != NULL;
    }];
}

OSStatus hotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData) {
    @autoreleasepool {
        EventHotKeyID hotKeyID;
        GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyID), NULL, &hotKeyID);
        
        UInt32 keyID = hotKeyID.id;
        
        NSSet *matchingHotKeys = [[HotKeyCenter sharedHotKey] hotKeysMatching:^BOOL(HotKey *hotkey) {
            return hotkey.hotKeyID == keyID;
        }];
        if ([matchingHotKeys count] > 1) { NSLog(@"ERROR!"); }
        HotKey *matchingHotKey = [matchingHotKeys anyObject];
        
        NSEvent *event = [NSEvent eventWithEventRef:theEvent];
        NSEvent *keyEvent = [NSEvent keyEventWithType:NSKeyUp
                                             location:[event locationInWindow]
                                        modifierFlags:[event modifierFlags]
                                            timestamp:[event timestamp]
                                         windowNumber:-1
                                              context:nil
                                           characters:@""
                          charactersIgnoringModifiers:@""
                                            isARepeat:NO
                                              keyCode:[matchingHotKey keyCode]];
        
        [matchingHotKey invokeWithEvent:keyEvent];
    }
    
    return noErr;
}

@end
