//
//  AppDelegate+XGConfig.m
//  XG-Demo-Cloud
//
//  Created by zq on 2019/12/3.
//  Copyright © 2019 XG of Tencent. All rights reserved.
//

#import "AppDelegate+XGConfig.h"
#import "ViewController.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate ()<XGPushDelegate>

@end

@implementation AppDelegate (XGConfig)

- (void)xgStart {
    [[XGPush defaultManager] setEnableDebug:YES];
    XGNotificationAction *action1 = [XGNotificationAction actionWithIdentifier:@"xgaction001" title:@"xgAction1" options:XGNotificationActionOptionNone];
    XGNotificationAction *action2 = [XGNotificationAction actionWithIdentifier:@"xgaction002" title:@"xgAction2" options:XGNotificationActionOptionDestructive];
    if (action1 && action2) {
        XGNotificationCategory *category = [XGNotificationCategory categoryWithIdentifier:@"xgCategory" actions:@[action1, action2] intentIdentifiers:@[] options:XGNotificationCategoryOptionNone];
        
        XGNotificationConfigure *configure = [XGNotificationConfigure configureNotificationWithCategories:[NSSet setWithObject:category] types:XGUserNotificationTypeAlert|XGUserNotificationTypeBadge|XGUserNotificationTypeSound];
        if (configure) {
            [[XGPush defaultManager] setNotificationConfigure:configure];
        }
    }

    [[XGPush defaultManager] startXGWithAppID:kAppID appKey:kAppKey delegate:self];
    // 清除角标
    if ([XGPush defaultManager].xgApplicationBadgeNumber > 0) {
        [[XGPush defaultManager] setXgApplicationBadgeNumber:0];
    }
}

#pragma mark - XGPushDelegate
- (void)xgPushDidFinishStart:(BOOL)isSuccess error:(NSError *)error {
    NSLog(@"%s, result %@, error %@", __FUNCTION__, isSuccess?@"OK":@"NO", error);
}

- (void)xgPushDidFinishStop:(BOOL)isSuccess error:(NSError *)error {
    UIViewController *ctr = [self.window rootViewController];
    if ([ctr isKindOfClass:[UINavigationController class]]) {
        ViewController *viewCtr = (ViewController *)[(UINavigationController *)ctr topViewController];
        [viewCtr updateNotification:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"unregister_app", nil), (isSuccess?NSLocalizedString(@"success", nil):NSLocalizedString(@"failed", nil))]];
    }
    
}

- (void)xgPushDidRegisteredDeviceToken:(NSString *)deviceToken error:(NSError *)error {
    NSLog(@"%s, result %@, error %@", __FUNCTION__, error?@"NO":@"OK", error);
    UIViewController *ctr = [self.window rootViewController];
    if ([ctr isKindOfClass:[UINavigationController class]]) {
        ViewController *viewCtr = (ViewController *)[(UINavigationController *)ctr topViewController];
        [viewCtr updateNotification:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"register_app", nil), (error == nil?NSLocalizedString(@"success", nil):NSLocalizedString(@"failed", nil))]];
    }
}

// iOS 10 新增 API
// iOS 10 会走新 API, iOS 10 以前会走到老 API
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// App 用户点击通知
// App 用户选择通知中的行为
// 无论本地推送还是远程推送都会走这个回调
- (void)xgPushUserNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    NSLog(@"[XGDemo] click notification");
    if ([response.actionIdentifier isEqualToString:@"xgaction001"]) {
        NSLog(@"click from Action1");
    } else if ([response.actionIdentifier isEqualToString:@"xgaction002"]) {
        NSLog(@"click from Action2");
    }
    completionHandler();
}

// App 在前台弹通知需要调用这个接口
//- (void)xgPushUserNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
//    [[XGPush defaultManager] reportXGNotificationInfo:notification.request.content.userInfo];
//    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
//}
#endif
/**
 统一收到通知消息的回调
 @param notification 消息对象
 @param completionHandler 完成回调
 */
- (void)xgPushDidReceiveRemoteNotification:(id)notification withCompletionHandler:(void (^)(NSUInteger))completionHandler {
    //NSLog(@"recieve message:%@", notification);
    if ([notification isKindOfClass:[NSDictionary class]]) {
        completionHandler(UIBackgroundFetchResultNewData);
    } else if ([notification isKindOfClass:[UNNotification class]]) {
        //NSLog(@"xg info :%@", ((UNNotification *)notification).request.content.userInfo);
        completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
    }
}

- (void)xgPushDidSetBadge:(BOOL)isSuccess error:(NSError *)error {
    NSLog(@"%s, result %@, error %@", __FUNCTION__, error?@"NO":@"OK", error);
}

@end
