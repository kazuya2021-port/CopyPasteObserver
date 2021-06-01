//
//  AppDelegate.m
//  CopyPasteObserver
//
//  Created by uchiyama_Macmini on 2018/04/17.
//  Copyright © 2018年 uchiyama_Macmini. All rights reserved.
//

#import "AppDelegate.h"
#import "appleScripts.h"

@interface AppDelegate ()
@property (weak) IBOutlet NSMenu *statusMenu;
@property (weak) IBOutlet NSWindow *window;

-(IBAction)showsetting:(id)sender;

@end

@implementation AppDelegate
{
    NSStatusItem* _statusItem;
    appleScripts* as;
    NSMutableArray* openedInfo;
}

@synthesize objCtrl;

BOOL isActiveIllustrator = NO;
BOOL isOptionKeyDown = NO;
EventHandlerRef kLogRef;
#define AI         @"Adobe Illustrator"

- (void)runLeyLogger
{
    EventTypeSpec klog;
    klog.eventClass = kEventClassKeyboard;
    klog.eventKind = kEventRawKeyDown;
    InstallEventHandler(GetEventMonitorTarget(), &kLogHandler, 1, &klog, (__bridge void *)(self), &kLogRef);
}

OSStatus kLogHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData) {
    AppDelegate* app = (__bridge AppDelegate*)(userData);
    [app onKeyDown];
    return noErr;
}

- (void)exitKeyLogge
{
    RemoveEventHandler(kLogRef);
}

- (void)awakeFromNib
{
    hotkey = nil;
    as = [[appleScripts alloc] init];
    objCtrl = [[ObjectInfoController alloc] init];
    openedInfo = [NSMutableArray array];
    wakuColor = [well color];
    wakuColor = [wakuColor colorUsingColorSpace:[NSColorSpace genericCMYKColorSpace]];
    //[self runLeyLogger];
}


- (void)setupStatusItem
{
    NSStatusBar* systemStatusBar = [NSStatusBar systemStatusBar];
    _statusItem = [systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    
    [_statusItem setHighlightMode:YES];
    //[_statusItem setTitle:@"CopyPaste"];
    [_statusItem setImage:[NSImage imageNamed:@"cpo.png"]];
    [_statusItem setMenu:self.statusMenu];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupStatusItem];
    
    
    [[[NSWorkspace sharedWorkspace] notificationCenter]
     addObserver:self
     selector:@selector(switchHandler:)
     name:NSWorkspaceDidDeactivateApplicationNotification
     object:nil];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter]
     addObserver:self
     selector:@selector(switchHandler:)
     name:NSWorkspaceDidActivateApplicationNotification
     object:nil];

    [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskFromType(NSFlagsChanged) handler:^(NSEvent * event) {
        if(isActiveIllustrator)
        {
            if(([event keyCode] == kVK_Option) && !isOptionKeyDown)
            {
                isOptionKeyDown = YES;
            }
            else if(([event keyCode] == kVK_Option) && isOptionKeyDown)
            {
                isOptionKeyDown = NO;
            }
        }
    }];
    
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskFromType(NSLeftMouseDragged) handler:^(NSEvent * event) {
        if(isActiveIllustrator)
        {
            [self onMouceDragg];
            if(isOptionKeyDown)
            {
                NSLog(@"dragg+Option:");
            }
        }
    }];
    
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskFromType(NSLeftMouseUp) handler:^(NSEvent * event) {
        if(isActiveIllustrator)
        {
            [self onMouceUp];
        }
    }];
    
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskFromType(NSLeftMouseDown) handler:^(NSEvent * event) {
        if(isActiveIllustrator)
        {
            [self onMouceDown];
        }
    }];
    
}

// アプリのアクティブ/非アクティブ
- (void) switchHandler:(NSNotification*) notification
{
    NSRunningApplication* app = [[notification userInfo] objectForKey:@"NSWorkspaceApplicationKey"];
    if ([[notification name] isEqualToString:
         NSWorkspaceDidActivateApplicationNotification])
    {
        if([CPOLib isExistString:[app localizedName] searchStr:AI])
        {
            if(hotkey == nil) hotkey = [HotKeyCenter sharedHotKey];
            if(![hotkey registerHotKeyWithKeyCode:kVK_ANSI_C modifierFlags:NSCommandKeyMask target:self action:@selector(copyAction) object:nil])
            {
                NSLog(@"Unable to register hotkey for copy");
            }
            if(![hotkey registerHotKeyWithKeyCode:kVK_ANSI_V modifierFlags:NSCommandKeyMask target:self action:@selector(pasteAction) object:nil])
            {
                NSLog(@"Unable to register hotkey for paste");
            }
            if(![hotkey registerHotKeyWithKeyCode:kVK_ANSI_Z modifierFlags:NSCommandKeyMask target:self action:@selector(undoAction) object:nil])
            {
                NSLog(@"Unable to register hotkey for undo");
            }
            if(![hotkey registerHotKeyWithKeyCode:kVK_ANSI_S modifierFlags:NSCommandKeyMask target:self action:@selector(saveAction) object:nil])
            {
                NSLog(@"Unable to register hotkey for undo");
            }
            isActiveIllustrator = YES;
            if([as checkOpened])
            {
                if([objCtrl.objInfos count] != 0)
                    [objCtrl removeObjectInfos:objCtrl.objInfos];
                openedInfo = [[as getAllObjectInfo] mutableCopy];
                [objCtrl addObjectInfos:openedInfo];
            }
            [self runLeyLogger];
            NSLog(@"regist hot key");
        }
    }
    else
    {
        if([CPOLib isExistString:[app localizedName] searchStr:AI])
        {
            if(hotkey == nil) hotkey = [HotKeyCenter sharedHotKey];
            [hotkey unregisterHotKeyWithKeyCode:kVK_ANSI_C modifierFlags:NSCommandKeyMask];
            [hotkey unregisterHotKeyWithKeyCode:kVK_ANSI_V modifierFlags:NSCommandKeyMask];
            [hotkey unregisterHotKeyWithKeyCode:kVK_ANSI_S modifierFlags:NSCommandKeyMask];
            [hotkey unregisterHotKeyWithKeyCode:kVK_ANSI_Z modifierFlags:NSCommandKeyMask];
            isActiveIllustrator = NO;
            isOptionKeyDown = NO;
            openedInfo = nil;
            openedInfo = [NSMutableArray array];
            [objCtrl removeObjectInfos:objCtrl.objInfos];
            [self exitKeyLogge];
            NSLog(@"unregist hot key");
        }
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    if(hotkey == nil) hotkey = [HotKeyCenter sharedHotKey];
    [hotkey unregisterHotKeyWithKeyCode:kVK_ANSI_C modifierFlags:NSCommandKeyMask];
    [hotkey unregisterHotKeyWithKeyCode:kVK_ANSI_V modifierFlags:NSCommandKeyMask];
    [hotkey unregisterHotKeyWithKeyCode:kVK_ANSI_S modifierFlags:NSCommandKeyMask];
    [hotkey unregisterHotKeyWithKeyCode:kVK_ANSI_Z modifierFlags:NSCommandKeyMask];
}

// オブジェクトの情報を保持
- (void) getAndAddObjectInfo
{
    if(![as checkIsTouchObject])
    {
        //[self isDiffContentsAll];
        return;
    }
    else
    {
        NSLog(@"selectedObj");
        ObjectInfo* objInfo = [as getObjectInfo];
        if(objInfo == nil) return;
        
        NSString* objID = [objInfo note];
        if([objID compare:@"AkaGroup"] == NSOrderedSame) return;
        ObjectInfo* oldInfo = [objCtrl getObjectIonfoFromNote:objID];
        
        if(oldInfo == nil)
        {
            objInfo.note = [NSString stringWithFormat:@"scriptSelect%lu",[objCtrl.objInfos count]];
            objID = objInfo.note;
            [objCtrl addObjectInfo:objInfo];
            [as addNote:objID];
            NSLog(@"addObject");
        }
        
        if([self isDiffPos:objInfo])
        {
            if(!oldInfo.isAka)
            {
                [as executeAka:wakuColor objID:oldInfo.note];
                [objCtrl setIsAka:objID isAka:YES];
            }
        }
    }
}

- (BOOL)isDiffPos:(ObjectInfo*) newObj
{
    NSString* curObjID = newObj.note;
    ObjectInfo* obj = [objCtrl getObjectIonfoFromNote:curObjID];
    NSArray* oldPos = obj.position;
    NSArray* newPos = newObj.position;
    
    NSLog(@"%@",obj);
    NSLog(@"%@",newObj);
    if(([[oldPos objectAtIndex:0] compare:[newPos objectAtIndex:0]] != NSOrderedSame) ||
       ([[oldPos objectAtIndex:1] compare:[newPos objectAtIndex:1]] != NSOrderedSame))
    {
        return YES;
    }
    if([obj.contents compare:newObj.contents] != NSOrderedSame)
    {
        return YES;
    }
    return NO;
}

- (void)isDiffContentsAll
{
    NSArray* allContents = [as getAllContentsInfo];
    
    for(ObjectInfo* curInfo in allContents)
    {
        BOOL isDiff = NO;
        ObjectInfo* oldObj;
        for(ObjectInfo* oldInfo in objCtrl.objInfos)
        {
            if([oldInfo.contents compare:curInfo.contents] != NSOrderedSame)
            {
                isDiff = YES;
                oldObj = oldInfo;
                break;
            }
        }
        if(isDiff)
        {
            if(!oldObj.isAka)
            {
                [as executeAka:wakuColor objID:oldObj.note];
                [objCtrl setIsAka:oldObj.note isAka:YES];
            }
        }
    }
}

- (void)onKeyDown
{
    NSLog(@"keyDown");
    //[self getAndAddObjectInfo];
}

- (void)onMouceDragg
{
    NSLog(@"************ dragg");
    if([as checkOpened])
    {
        if([objCtrl.objInfos count] == 0)
        {
            [as setAllObjectNote];
            [objCtrl addObjectInfos:openedInfo];
        }
        [self getAndAddObjectInfo];
    }
    else
        [objCtrl removeObjectInfos:objCtrl.objInfos];
}
- (void)onMouceDown
{
    NSLog(@"************ down");
    if([as checkOpened])
    {
        if([objCtrl.objInfos count] == 0)
        {
            [as setAllObjectNote];
            [objCtrl addObjectInfos:openedInfo];
        }
        [self getAndAddObjectInfo];
    }
    else
        [objCtrl removeObjectInfos:objCtrl.objInfos];
}
- (void)onMouceUp
{
    NSLog(@"************ up");
    if([as checkOpened])
    {
        if([objCtrl.objInfos count] == 0)
        {
            [as setAllObjectNote];
            [objCtrl addObjectInfos:openedInfo];
        }
        [self getAndAddObjectInfo];
    }
    else
        [objCtrl removeObjectInfos:objCtrl.objInfos];
}

- (void)undoAction
{
    [objCtrl undo];
    [as executeUndo];
}
- (void)saveAction
{
    NSLog(@"saveAction");
    [as deleteAllAka];
    [objCtrl setIsAkaFalse];
    [as saveAI];
    if([objCtrl.objInfos count] != 0)
        [objCtrl removeObjectInfos:objCtrl.objInfos];
    openedInfo = [[as getAllObjectInfo] mutableCopy];
    [objCtrl addObjectInfos:openedInfo];
}

- (void)copyAction
{
    NSLog(@"copyAction");
    if([as checkOpened])
    {
        if([objCtrl.objInfos count] == 0)
        {
            [as setAllObjectNote];
            [objCtrl addObjectInfos:openedInfo];
        }
        [as executeCopy];
    }
    else
        [objCtrl removeObjectInfos:objCtrl.objInfos];
}

- (void)pasteAction
{
    NSLog(@"pasteAction");
    if([as checkOpened])
    {
        if([objCtrl.objInfos count] == 0)
        {
            [as setAllObjectNote];
            [objCtrl addObjectInfos:openedInfo];
        }
        [as executePaste];
        [as executeAka:wakuColor objID:nil];
        if(![as checkIsTouchObject]) return;
        ObjectInfo* objInfo = [as getObjectInfo];
        NSString* objID = [objInfo note];
        [objCtrl setIsAka:objID isAka:YES];
    }
    else
        [objCtrl removeObjectInfos:objCtrl.objInfos];
}








-(IBAction)showsetting:(id)sender
{
    [_window makeKeyAndOrderFront:nil];
}

- (IBAction)appendSetting:(id)sender
{
    wakuColor = [well color];
    wakuColor = [wakuColor colorUsingColorSpace:[NSColorSpace genericCMYKColorSpace]];
}

@end
