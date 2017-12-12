//
//  AppDelegate.m
//  RecordAndPlayVoice
//
//  Created by pengjie on 2016/11/27.
//  Copyright © 2016年 pengjie. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CallKit/CallKit.h>
#import "LVRecordTool.h"

@interface AppDelegate ()<CXCallObserverDelegate>

@property (strong, nonatomic) CXCallObserver *callObserver;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    CXCallObserver *callObserver = [[CXCallObserver alloc] init];
    [callObserver setDelegate:self queue:nil];
    self.callObserver = callObserver;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call{
    if (call.hasEnded) {
        NSLog(@"挂断了电话咯   Call has been disconnected");
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          [[LVRecordTool sharedRecordTool] resumeRecording];
          });
    }else if (call.hasConnected){
        NSLog(@"电话通了Call has just been connected");
    }else if(call.onHold){
        NSLog(@"来电话了Call is incoming");
        [[LVRecordTool sharedRecordTool] pauseRecording];
    }else if (call.outgoing){
         NSLog(@"电话不通");
    }
}

@end
