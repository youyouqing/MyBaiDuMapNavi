//
//  AppDelegate.m
//  BBBB
//
//  Created by zhangmin on 2018/5/23.
//  Copyright © 2018年 zhangmin. All rights reserved.
//

#import "AppDelegate.h"
//#import<BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import "BNCoreServices.h"
#define BNAVI_APP_KEY       @"cMEqDYQScfg60t46ufAMfu0wUzHdFFN3"
//语音开放平台注册
#define TTS_APP_ID          @"10881846"
#define TTS_API_KEY         @"cMEqDYQScfg60t46ufAMfu0wUzHdFFN3"
#define TTS_SECRET_KEY      @"aaxDmiQ7V98DowELgPCXwv1EU31E3ifS"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //启动服务
    [BNCoreServices_Instance startServicesAsyn:^{
        //导航SDK鉴权
        [BNCoreServices_Instance authorizeNaviAppKey:BNAVI_APP_KEY
                                          completion:^(BOOL suc) {
                                              NSLog(@"authorizeNaviAppKey ret = %d",suc);
                                          }];
        //TTS SDK鉴权
        [BNCoreServices_Instance authorizeTTSAppId:TTS_APP_ID
                                            apiKey:TTS_API_KEY
                                         secretKey:TTS_SECRET_KEY
                                        completion:^(BOOL suc) {
                                            NSLog(@"authorizeTTS ret = %d",suc);
                                        }];
    } fail:nil];    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
