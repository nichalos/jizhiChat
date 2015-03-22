//
//  AppDelegate.h
//  Demo
//
//  Created by Junfeng Bai on 15/3/3.
//  Copyright (c) 2015年 artron. All rights reserved.
//
#define kKeyboardBtnpng             @"dial_icon.png"
#define kKeyboardBtnOnpng           @"dial_icon_on.png"
#define kHandsfreeBtnpng            @"handsfree_icon.png"
#define kHandsfreeBtnOnpng          @"handsfree_icon_on.png"
#define kMuteBtnpng                 @"mute_icon.png"
#define kMuteBtnOnpng               @"mute_icon_on.png"
#define kTransferCallBtnpng         @"call_transfer_icon.png"
#define kTransferCallBtnOnpng       @"call_transfer_icon_on.png"
#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *friendList;

@end

