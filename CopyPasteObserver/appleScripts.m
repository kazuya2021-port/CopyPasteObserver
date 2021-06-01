//
//  appleScripts.m
//  CopyPasteObserver
//
//  Created by uchiyama_Macmini on 2018/04/19.
//  Copyright © 2018年 uchiyama_Macmini. All rights reserved.
//

#import "appleScripts.h"

@implementation appleScripts

- (NSAppleEventDescriptor*)executeScript:(NSString*) source
{
    NSError* err;
    NSDictionary  *asErrDic = nil;
    [source writeToURL:[NSURL fileURLWithPath:@"/Applications/FACILIS Supremo/OutPDF/test.applescript"] atomically:NO encoding:NSUTF8StringEncoding error:&err];
    NSAppleScript* as = [[NSAppleScript alloc] initWithSource:source];
    NSAppleEventDescriptor* result = [as executeAndReturnError : &asErrDic ];
    if ( asErrDic ) {
        NSLog(@"%@",[asErrDic objectForKey:NSAppleScriptErrorMessage]);
        return nil;
    }
    return result;
}

// オブジェクトの情報取得
- (ObjectInfo*)getObjectInfo
{
    NSString* ass = [NSString stringWithFormat:@""
                     "with timeout of (1 * 60 * 60) seconds\n"
                     "    tell application \"Adobe Illustrator\"\n"
                     "        set ginfo to \"%@\"\n"
                     "        do javascript(file ginfo)\n"
                     "    end tell\n"
                     "end timeout",
                     [RESPATH stringByAppendingPathComponent:@"getObjInfo.jsx"]];
    NSString* retStr = [[self executeScript:ass] stringValue];
    id o = [CPOLib getObjectInfoFromJSONstr:retStr];
    return o;
}

// ファイル保存
- (void)saveAI
{
    NSString* ass = @""
                     "with timeout of (1 * 60 * 60) seconds\n"
                     "    tell application \"Adobe Illustrator\"\n"
                     "        set f_path to file path of current document\n"
                     "        set f_path to POSIX path of f_path\n"
                     "        save current document in file f_path as Illustrator with options {class:Illustrator save options, PDF compatible:true} \n"
                     "    end tell\n"
                     "end timeout";
    [self executeScript:ass];
}

// 全オブジェクトの情報取得
- (NSArray*)getAllObjectInfo
{
    NSString* ass = [NSString stringWithFormat:@""
                     "with timeout of (1 * 60 * 60) seconds\n"
                     "    tell application \"Adobe Illustrator\"\n"
                     "        set ginfo to \"%@\"\n"
                     "        do javascript(file ginfo)\n"
                     "    end tell\n"
                     "end timeout\n",
                     [RESPATH stringByAppendingPathComponent:@"getAllInfo.jsx"]];
    NSString* retStr = [[self executeScript:ass] stringValue];
    
    return [CPOLib getObjectInfosFromJSONstr:retStr];
}

// 全テキストのコンテンツ取得
- (NSArray*)getAllContentsInfo
{
    NSString* ass = [NSString stringWithFormat:@""
                     "with timeout of (1 * 60 * 60) seconds\n"
                     "    tell application \"Adobe Illustrator\"\n"
                     "        set ginfo to \"%@\"\n"
                     "        do javascript(file ginfo)\n"
                     "    end tell\n"
                     "end timeout\n",
                     [RESPATH stringByAppendingPathComponent:@"getAllContents.jsx"]];
    NSString* retStr = [[self executeScript:ass] stringValue];
    
    return [CPOLib getObjectInfosFromJSONstr:retStr];
}

- (void)setAllObjectNote
{
    NSString* ass = [NSString stringWithFormat:@""
                     "with timeout of (1 * 60 * 60) seconds\n"
                     "    tell application \"Adobe Illustrator\"\n"
                     "        set ginfo to \"%@\"\n"
                     "        do javascript(file ginfo)\n"
                     "    end tell\n"
                     "end timeout\n",
                     [RESPATH stringByAppendingPathComponent:@"setAllObjNote.jsx"]];
    [self executeScript:ass];
}
// 待ちアクション
- (void)delay:(int)wait
{
    NSString* ass = [NSString stringWithFormat:@""
    "delay %d\n",wait];
    [self executeScript:ass];
}

// オブジェクトを選択しているかどうか？
- (BOOL)checkIsTouchObject
{
    NSString* ass = [NSString stringWithFormat:@""
                     "with timeout of (1 * 60 * 60) seconds\n"
                     "    tell application \"Adobe Illustrator\"\n"
                     "        set chk to \"%@\"\n"
                     "        do javascript(file chk)\n"
                     "    end tell\n"
                     "end timeout",
                     [RESPATH stringByAppendingPathComponent:@"chkSelObj.jsx"]];
    return ([[[self executeScript:ass] stringValue] compare:@"true"] == NSOrderedSame)? YES: NO;
}

// コピーアクション
- (void)executeCopy
{
    NSString* ass = @""
    "with timeout of (1 * 60 * 60) seconds\n"
    "    tell application \"Adobe Illustrator\"\n"
    "        copy\n"
    "    end tell\n"
    "end timeout";
    [self executeScript:ass];
}

- (void)executeUndo
{
    NSString* ass = @""
    "with timeout of (1 * 60 * 60) seconds\n"
    "    tell application \"Adobe Illustrator\"\n"
    "        undo\n"
    "    end tell\n"
    "end timeout";
    [self executeScript:ass];
}
// ペーストアクション
- (void)executePaste
{
    NSString* ass = @""
                     "with timeout of (1 * 60 * 60) seconds\n"
                     "    tell application \"Adobe Illustrator\"\n"
                     "        paste\n"
                     "    end tell\n"
                     "end timeout";
    [self executeScript:ass];
}

// 赤枠アクション
- (void)executeAka:(NSColor*)color objID:(NSString*)objID
{
    CGFloat c = [color cyanComponent] * 100;
    CGFloat m = [color magentaComponent] * 100;
    CGFloat y = [color yellowComponent] * 100;
    CGFloat k = [color blackComponent] * 100;
    NSString* ass = [NSString stringWithFormat:@""
                     "with timeout of (1 * 60 * 60) seconds\n"
                     "    tell application \"Adobe Illustrator\"\n"
                     "        set aka to \"%@\"\n"
                     "        do javascript(file aka) with arguments {%f,%f,%f,%f, \"%@\"}\n"
                     "    end tell\n"
                     "end timeout",
                     [RESPATH stringByAppendingPathComponent:@"makeAkaWaku.jsx"],
                     c,m,y,k,
                     objID];
    [self executeScript:ass];
}

// ドキュメントオープンチェック
- (BOOL)checkOpened
{
    NSString* ass = [NSString stringWithFormat:@""
                     "with timeout of (1 * 60 * 60) seconds\n"
                     "    tell application \"Adobe Illustrator\"\n"
                     "        set chk to \"%@\"\n"
                     "        do javascript(file chk)\n"
                     "    end tell\n"
                     "end timeout",
                     [RESPATH stringByAppendingPathComponent:@"checkOpened.jsx"]];
    return ([[[self executeScript:ass] stringValue] compare:@"true"] == NSOrderedSame)? YES: NO;
}

// noteの書き換え
- (void)addNote:(NSString*)str
{
    NSString* ass = [NSString stringWithFormat:@""
                     "with timeout of (1 * 60 * 60) seconds\n"
                     "    tell application \"Adobe Illustrator\"\n"
                     "        set anote to \"%@\"\n"
                     "        do javascript(file anote) with arguments {\"%@\"}\n"
                     "    end tell\n"
                     "end timeout",
                     [RESPATH stringByAppendingPathComponent:@"addNote.jsx"],
                     str];
    [self executeScript:ass];
}

// 赤枠の削除
- (void)deleteAllAka
{
    NSString* ass = [NSString stringWithFormat:@""
                     "with timeout of (1 * 60 * 60) seconds\n"
                     "    tell application \"Adobe Illustrator\"\n"
                     "        set anote to \"%@\"\n"
                     "        do javascript(file anote)\n"
                     "    end tell\n"
                     "end timeout",
                     [RESPATH stringByAppendingPathComponent:@"deleteAkaWaku.jsx"]];
    [self executeScript:ass];
}
@end
