//
//  AppDelegate.m
//  Demo
//
//  Created by Junfeng Bai on 15/3/3.
//  Copyright (c) 2015年 artron. All rights reserved.
//

#import "AppDelegate.h"
#import "RCIM.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import <ShareSDK/ShareSDK.h>
#import <libNBSAppAgent/NBSAppAgent.h>
#import "DemoCommonConfig.h"
#import "DemoUIConstantDefine.h"
#import "VoiChannelAPI.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //注册听云
    [NBSAppAgent startWithAppID:@"179f3329cd4d40db84c4c35fa5f2211e"];
    
    //注册融云
    [RCIM initWithAppKey:@"mgb7ka1nbs6bg" deviceToken:nil];

#ifdef __IPHONE_8_0
    // 在 iOS 8 下注册苹果推送，申请推送权限。
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge
                                                                                         |UIUserNotificationTypeSound
                                                                                         |UIUserNotificationTypeAlert) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
#else
    // 注册苹果推送，申请推送权限。
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
#endif
    
    
    //注册shareSDK
    [ShareSDK registerApp:@"600bcd887a6a"];
    [ShareSDK connectSinaWeiboWithAppKey:@"3434951909" appSecret:@"738dcd12ef9b756b53ff667456c64655" redirectUri:@"http://www.baidu.com"];
    [[VoiChannelAPI defaultAPI] setAppKey:@"380b461b-d67f-4714-abd2-08e5c0560474"];
    return YES;
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    // Register to receive notifications.
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    // Handle the actions.
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif

// 获取苹果推送权限成功。
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // 设置 deviceToken。
    [[RCIM sharedRCIM] setDeviceToken:deviceToken];
}


// 获取好友列表的方法。
-(NSArray*)getFriends
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    RCUserInfo *user1 = [[RCUserInfo alloc]init];
    user1.userId = @"1";
    user1.name = @"韩梅梅";
    user1.portraitUri = @"http://rongcloud-web.qiniudn.com/docs_demo_rongcloud_logo.png";
    [array addObject:user1];
    
    RCUserInfo *user2 = [[RCUserInfo alloc]init];
    user2.userId = @"2";
    user2.name = @"李雷";
    user2.portraitUri = @"http://rongcloud-web.qiniudn.com/docs_demo_rongcloud_logo.png";
    [array addObject:user2];
    
    return array;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}


-(NSString*)readAppKeyFromConfig
{
    //    return RONGCLOUD_IM_APPKEY;
    
    NSString *pAppKeyPath = [[NSBundle mainBundle] pathForResource:RC_APPKEY_CONFIGFILE ofType:@""];//[documentsDir stringByAppendingPathComponent:RC_APPKEY_CONFIGFILE];
    NSError *error;
    NSString *valueOfKey = [NSString stringWithContentsOfFile:pAppKeyPath encoding:NSUTF8StringEncoding error:&error];
    NSString* appKey;
    if([valueOfKey intValue] == 0)  //开发环境：0 生产环境：1
        appKey = @"";//@"uwd1c0sxdlx91";
    else
        appKey = @"mgb7ka1nbs6bg";//@"8luwapkvuxvel";
    return appKey;
}


@end
