//
//  HomeViewController.m
//  iOS-IMKit-demo
//
//  Created by xugang on 7/24/14.
//  Copyright (c) 2014 Heq.Shinoda. All rights reserved.
//

#import "HomeViewController.h"
#import "UserDataModel.h"
#import "UserInfoViewController.h"
#import "DemoChatListViewController.h"
#import "DemoChatViewController.h"
#import "RCHandShakeMessage.h"
#import "RCGroup.h"
#import "DemoCommonConfig.h"
#import "DemoRichContentMessageViewController.h"
#import "DemoBlacklistViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <SinaWeiboConnection/SinaWeiboConnection.h>
#import "ChannelViewController.h"



@interface HomeViewController ()<RCIMConnectionStatusDelegate,RCIMGroupInfoFetcherDelegate>

@end

@implementation HomeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.groupList = [[NSMutableArray alloc]init];
        
        RCGroup *group001 = [[RCGroup alloc]init];
        group001.groupId = @"group001";
        group001.groupName =@"基智群组";
        group001.portraitUri = @"https://i0.wp.com/developer.files.wordpress.com/2013/01/60b40db1e3946a29262eda6c78f33123.jpg?w=100";
        [_groupList addObject:group001];
        
        [[RCIMClient sharedRCIMClient]syncGroups:_groupList completion:^{
            
        } error:^(RCErrorCode status) {
            DebugLog(@"同步群数据status%d",(int)status);
        }];
        
        
        
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    
    UIView *aView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    [aView setBackgroundColor:[UIColor whiteColor]];
    
    self.view =aView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout =UIRectEdgeNone;
    
    [[RCIM sharedRCIM] setReceiveMessageDelegate:self];
//     NSArray *segmentedArray = @[@"默认",@"自定义"];
//    self.segment = [[UISegmentedControl alloc]initWithItems:segmentedArray];
//    self.segment.selectedSegmentIndex = 0;
//    self.segment.tintColor = [UIColor whiteColor];
//    self.navigationItem.titleView  = self.segment;
    
    
    [[RCIM sharedRCIM] setUserPortraitClickEvent:^(UIViewController *viewController, RCUserInfo *userInfo) {
        DebugLog(@"%@,%@",viewController,userInfo);
        if ([[UserManager shareMainUser ].mainUser.userId isEqualToString:userInfo.userId]) {
            return ;
        }
        DemoChatViewController *temp = [[DemoChatViewController alloc]init];
        
        temp.currentTarget = userInfo.userId;
        temp.conversationType = ConversationType_PRIVATE;
        temp.currentTargetName = userInfo.name;
        temp.enableSettings = YES;
        temp.enablePOI = YES;
        temp.enableVoIP = YES;
        temp.portraitStyle = RCUserAvatarCycle;
        [self.navigationController pushViewController:temp animated:YES];
    }];
    [RCIM setGroupInfoFetcherWithDelegate:self];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.hidden =NO;
    self.title = @"基智chat";
    self.dataList = [[NSMutableArray alloc] initWithObjects:@"会话列表", @"基智群组",@"基智聊天室",@"基智BB", @"退出账号",nil] ;
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style: UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizesSubviews  = YES;
    self.tableView.autoresizingMask=UIViewAutoresizingFlexibleHeight;
    self.tableView.rowHeight = 65;
    
    [self.view addSubview:self.tableView];
}


-(void)viewWillAppear:(BOOL)animated
{
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    }
    
    
    [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
    
    //清空会话列表使用，请不要打开注释
    //[[RCIMClient sharedRCIMClient]clearConversations:ConversationType_PRIVATE,ConversationType_GROUP,ConversationType_DISCUSSION,nil];
    //[[RCIM sharedRCIM]clearConversations:ConversationType_PRIVATE,ConversationType_GROUP,ConversationType_DISCUSSION,nil];
    
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[RCIM sharedRCIM] setConnectionStatusDelegate:nil];
}

-(void)responseConnectionStatus:(RCConnectionStatus)status{
    if (ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT == status) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"" message:@"您已下线，重新连接？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: @"确定",nil];
            alert.tag = 2000;
            [alert show];
        });
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdetify = @"SvTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdetify];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = (self.dataList)[indexPath.row];
    if (indexPath.row == _dataList.count-1) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (0==indexPath.row) {
        
        DemoChatListViewController *temp = [[DemoChatListViewController alloc]init];
        temp.portraitStyle = RCUserAvatarCycle;

        [self.navigationController pushViewController:temp animated:YES];
        
        //[[RCIM sharedRCIM] launchConversationList:self];
    }
    
    if (1 == indexPath.row) {
        
        RCGroup *group = _groupList[0];
        
        RCChatViewController *temp = [[RCChatViewController alloc]init];
        temp.currentTarget = group.groupId;
        temp.conversationType = ConversationType_GROUP;
        temp.currentTargetName = group.groupName;
        temp.enableUnreadBadge = NO;
        temp.enableVoIP = NO;
        temp.portraitStyle = RCUserAvatarCycle;
        [self.navigationController pushViewController:temp animated:YES];
        
    }
    
    if (2 == indexPath.row) {
        
        
        RCChatViewController *temp = [[RCChatViewController alloc]init];
        temp.currentTarget = @"chatroom002";
        temp.conversationType = ConversationType_CHATROOM;
        temp.enableSettings = NO;
        temp.currentTargetName = @"基智聊天室";
        temp.portraitStyle = RCUserAvatarCycle;
        [self.navigationController pushViewController:temp animated:YES];
        
    }
    if (3 == indexPath.row){
        ChannelViewController *temp = [[ChannelViewController alloc] init];
//        if ([_currentUserId isEqualToString:@"2"]) {
//            temp.loginId = @"2";
//            temp.loginName = @"zy";
//        }else if([_currentUserId isEqualToString:@"1"]){
//            temp.loginId = @"1";
//            temp.loginName = @"zz";
//        }else if([_currentUserId isEqualToString:@"3"]){
//            temp.loginId = @"3";
//            temp.loginName = @"zz";
//        }else if([_currentUserId isEqualToString:@"4"]){
//            temp.loginId = @"4";
//            temp.loginName = @"xzy";
//        }else if([_currentUserId isEqualToString:@"5"]){
//            temp.loginId = @"5";
//            temp.loginName = @"xwj";
//        }else if([_currentUserId isEqualToString:@"6"]){
//            temp.loginId = @"6";
//            temp.loginName = @"xlb";
//        }else if([_currentUserId isEqualToString:@"7"]){
//            temp.loginId = @"7";
//            temp.loginName = @"zz";
//        }
        temp.loginId = [UserManager shareMainUser ].mainUser.userId;
        temp.loginName = [UserManager shareMainUser ].mainUser.username;
        [self.navigationController pushViewController:temp animated:YES];
    }
    //注销
    if (4 == indexPath.row) {
        [[RCIM sharedRCIM] disconnect:NO];
        [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


-(void)didReceivedMessage:(RCMessage *)message left:(int)nLeft
{
    if (0 == nLeft) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber+1;
        });
    }
    
    [[RCIM sharedRCIM] invokeVoIPCall:self message:message];
    //[[RCIM sharedRCIM]invokeVIOPCall:self message:message];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(NSString*)getKeFuId
{
    NSString *pAppKeyPath = [[NSBundle mainBundle] pathForResource:RC_APPKEY_CONFIGFILE ofType:@""];//[documentsDir stringByAppendingPathComponent:RC_APPKEY_CONFIGFILE];
    NSError *error;
    NSString *valueOfKey = [NSString stringWithContentsOfFile:pAppKeyPath encoding:NSUTF8StringEncoding error:&error];
    NSString* keFuId;
    if([valueOfKey intValue] == 0)  //开发环境：0 生产环境：1
        keFuId = @"rongcloud.net.kefu.service112";
    else
        keFuId = @"kefu114";
    return keFuId;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (2000 == alertView.tag) {
        
        if (0 == buttonIndex) {
            
            DebugLog(@"NO");
        }
        
        if (1 == buttonIndex) {
            
            DebugLog(@"YES");
            
            [RCIMClient reconnect:nil];
        }
    }
    
}

#pragma mark - RCIMGroupInfoFetcherDelegate method
-(void)getGroupInfoWithGroupId:(NSString*)groupId completion:(void (^)(RCGroup *group))completion
{
    RCGroup *group  = nil;
    if([groupId length] == 0)
        return completion(nil);
    for(RCGroup *__g in self.groupList)
    {
        if([__g.groupId isEqualToString:groupId])
        {
            group = __g;
            break;
        }
    }
    return completion(group);
}
@end
