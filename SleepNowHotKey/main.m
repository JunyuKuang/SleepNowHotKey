//
//  main.m
//  SleepNowHotKey
//
//  Created by Jonny Kuang on 8/26/23.
//

@import AppKit;
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    NSApplication *app = NSApplication.sharedApplication;
    AppDelegate *delegate = [[AppDelegate alloc] init];
    
    app.delegate = delegate;
    [app run];
}
