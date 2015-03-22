//
//  ViewController.h
//  Demo
//
//  Created by Junfeng Bai on 15/3/3.
//  Copyright (c) 2015年 artron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCHttpRequest.h"

@interface ViewController : UIViewController<HttpConnectionDelegate, UITextFieldDelegate>{
    NSString *loginToken;
    NSString *userName;
    NSString *userIcon;
}

@property (nonatomic,strong) RCHttpRequest *loginRequest;
@property (nonatomic,strong) RCHttpRequest *friendRequest;

@property (nonatomic,retain) UITextField *tf_Account;
@property (nonatomic,retain) NSString* voipAccount;
@property (nonatomic,retain) UIScrollView *scrollView;
@end

