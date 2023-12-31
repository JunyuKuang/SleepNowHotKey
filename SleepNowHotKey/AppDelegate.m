//
//  AppDelegate.m
//  SleepNowHotKey
//
//  Created by Jonny Kuang on 8/26/23.
//

#import "AppDelegate.h"
@import Carbon;
@import ServiceManagement;

static void sleepNow(void)
{
    [NSTask launchedTaskWithExecutableURL:[NSURL fileURLWithPath:@"/bin/sh"]
                                arguments:@[@"-c", @"pmset sleepnow"]
                                    error:nil
                       terminationHandler:nil];
}

static OSStatus HotKeyEventCallback(EventHandlerCallRef _, EventRef event, void *context)
{
    sleepNow();
    return noErr;
}

@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    CGRequestPostEventAccess();
    [self configureHotKeys];
    [self configureLaunchAtLogin];
    [self configureAutoSleepTimer];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    sleepNow();
    return NO;
}

- (void)configureHotKeys
{
    EventTargetRef target = GetApplicationEventTarget();
    EventTypeSpec spec = {
        .eventClass = kEventClassKeyboard,
        .eventKind = kEventHotKeyPressed
    };
    InstallEventHandler(target, HotKeyEventCallback, 1, &spec, nil, nil);
    
    EventHotKeyRef hotKeyRef;
    
    EventHotKeyID hotKeyID = {
        .signature = 'JONY',
        .id = 1
    };
    RegisterEventHotKey(kVK_ANSI_Q, optionKey, hotKeyID, target, 0, &hotKeyRef);
    
//    hotKeyID.id = 2;
//    RegisterEventHotKey(kVK_ANSI_S, optionKey, hotKeyID, target, 0, &hotKeyRef);
}

- (void)configureLaunchAtLogin
{
    if (@available(macOS 13.0, *)) {
        [SMAppService.mainAppService registerAndReturnError: nil];
    }
}

- (void)configureAutoSleepTimer
{
    NSNotificationCenter *notificationCenter = NSWorkspace.sharedWorkspace.notificationCenter;
    __block NSTimer *timer;
    
    [notificationCenter addObserverForName:NSWorkspaceScreensDidWakeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        [timer invalidate];
    }];
    [notificationCenter addObserverForName:NSWorkspaceScreensDidSleepNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        [timer invalidate];
        timer = [NSTimer scheduledTimerWithTimeInterval:60 * 60 repeats:NO block:^(NSTimer * _Nonnull timer) {
            sleepNow();
        }];
    }];
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
