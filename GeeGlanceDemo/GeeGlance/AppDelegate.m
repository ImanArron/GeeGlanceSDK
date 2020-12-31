//
//  AppDelegate.m
//  Glance
//
//  Created by noctis on 2020/8/27.
//  Copyright © 2020 com.geetest. All rights reserved.
//

#import "AppDelegate.h"
#import <GeeGlanceSDK/GeeGlanceSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // Glance
    [GeeGlanceManager enableLog:YES];   // 开启日志，建议开发调试阶段打开，上线时关闭
    [GeeGlanceManager registerWithMerchantId:@"4c73730ddc83ebc6f9b0af0d0e350590"];  // 传入 merchantId，初始化 SDK
    [GeeGlanceManager setUid:@"geetest"];   // 传入用户 id(可选)
    NSLog(@"GlanceSDK Version: %@", [GeeGlanceManager sdkVersion]); // SDK 版本
    
    return YES;
}

@end
