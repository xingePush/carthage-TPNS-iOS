//
//  NotificationService.m
//  XGService
//
//  Created by uwei on 09/08/2017.
//  Copyright © 2017 tyzual. All rights reserved.
//

#import "NotificationService.h"
#import <UIKit/UIKit.h>
#import "XGExtension.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    
    // 开启重复消息替换
    [XGExtension defaultManager].isDeduplication = YES;
    
    // 设置当收到重复消息时需要替换的消息
    [XGExtension defaultManager].defaultTitle = @"";
    [XGExtension defaultManager].defaultSubtitle = @"";
    [XGExtension defaultManager].defaultUserInfo = @{};
    [XGExtension defaultManager].defaultContent = @"因为内容重复而被替换的消息";
    
    [[XGExtension defaultManager] handleNotificationRequest:request appID:1600001061 appKey:@"IMC341U0L072" replaceContentHandler:^(UNNotificationContent * _Nullable content, NSError * _Nullable error, BOOL isRepeat) {
        self.bestAttemptContent = [content mutableCopy];
        self.contentHandler(content);
    }];
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
