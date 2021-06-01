//
//  AppDelegate.h
//  CopyPasteObserver
//
//  Created by uchiyama_Macmini on 2018/04/17.
//  Copyright © 2018年 uchiyama_Macmini. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <CoreGraphics/CoreGraphics.h>
#import "HotKey.h"
#import "ObjectInfoController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    HotKeyCenter* hotkey;
    ObjectInfoController* objCtrl;
    NSColor* wakuColor;
    IBOutlet NSColorWell* well;
}
@property (nonatomic, retain)ObjectInfoController* objCtrl;

- (IBAction)appendSetting:(id)sender;
@end

