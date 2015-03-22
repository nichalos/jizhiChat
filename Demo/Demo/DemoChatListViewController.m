//
//  DemoChatListViewController.m
//  Demo
//
//  Created by Junfeng Bai on 15/3/5.
//  Copyright (c) 2015年 artron. All rights reserved.
//

#import "DemoChatListViewController.h"

@interface DemoChatListViewController ()

@end

@implementation DemoChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationTitle:@"会话" textColor:[UIColor whiteColor]];
    
    // 自定义导航左右按钮
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemPressed:)];
    [leftButton setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    // 自定义导航左右按钮
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"选择" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemPressed:)];
    [rightButton setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = rightButton;
}


-(void)leftBarButtonItemPressed:(id)sender
{
    [super leftBarButtonItemPressed:sender];
}

-(void)rightBarButtonItemPressed:(id)sender
{
    // 跳转好友列表界面，可是是融云提供的 UI 组件，也可以是自己实现的UI
    RCSelectPersonViewController *temp = [[RCSelectPersonViewController alloc]init];
    
    // 控制多选
    temp.isMultiSelect = YES;
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:temp];
    
    // 导航和的配色保持一直
    UIImage *image= [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    temp.delegate = self;
    [self presentViewController:nav animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
