//
//  ChannelViewController.m
//  Demo
//
//  Created by nichalos on 15/3/18.
//  Copyright (c) 2015年 artron. All rights reserved.
//

#import "ChannelViewController.h"
#import "Toast+UIView.h"

@implementation Member

- (id)initWithUserId:(NSString*)userid nickname:(NSString*)name {
    self = [super init];
    
    _userId = userid;
    _nickname = name;
    _type = Common;
    
    return self;
}

@end


@interface ChannelViewController (){
    VoiChannelAPI *api;
    NSMutableArray *memberList;
    //当前频道状态
    TalkMode currentMode;
    GotyeChannelInfo *currentChannel;
    BOOL isLogin, isInChannel, isMuted;
    NSTimer *timer;
    UITableView *tableViewMemberList;
}

@end

@implementation ChannelViewController

- (Member *)getMemberByUserId:(NSString*) userId {
    for(Member *member in memberList) {
        if ([member.userId isEqualToString:userId]) {
            return member;
        }
    }
    
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    tableViewMemberList = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, CGRectGetWidth(self.view.frame), 240)];
    tableViewMemberList.delegate = self;
    tableViewMemberList.dataSource = self;
    [self.view addSubview:tableViewMemberList];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(CGRectGetWidth(self.view.frame)-60, CGRectGetHeight(self.view.frame)-40, 50, 30);
    [button setTitle:@"静音" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(selfMute:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
//
//    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
//    button1.frame = CGRectMake(CGRectGetMinX(button.frame)-100, CGRectGetHeight(self.view.frame)-40, 100, 30);
//    [button1 setTitle:@"进入频道" forState:UIControlStateNormal];
//    [button1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [button1 addTarget:self action:@selector(joinChannel:) forControlEvents:UIControlEventTouchUpInside];
//    button1.selected = YES;
//    [self.view addSubview:button1];
//    
//    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
//    button3.frame = CGRectMake(CGRectGetMinX(button1.frame)-60, CGRectGetHeight(self.view.frame)-40, 50, 30);
//    [button3 setTitle:@"登出" forState:UIControlStateNormal];
//    [button3 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [button3 addTarget:self action:@selector(exit:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:button3];
    
    memberList = [NSMutableArray array];
    api = [VoiChannelAPI defaultAPI];
    [api addListener:self];
    GotyeLoginInfo *info = [[GotyeLoginInfo alloc] initWithUserId:_loginId password:nil nickname:_loginName];
    [api setLoginInfo:info];
    
    currentChannel = [[GotyeChannelInfo alloc] initWithToken:@"265087" password:nil];
    [api joinChannel:currentChannel];
//    if (timer == nil || ![timer isValid]) {
//        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateBytes) userInfo:nil repeats:YES];
//    }
//    [timer fire];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [timer invalidate];
//    timer = nil;
    [api exit];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [api removeListener:self];
}
- (void)exit:(id)sender {
    [api stopTalking];
    [api exit];
}

- (void)joinChannel:(UIButton *)sender {
    [sender setSelected:!sender.selected];
    if (sender.selected) {
        [sender setTitle:@"进入频道" forState:UIControlStateNormal];
        [api exitChannel];
        [timer invalidate];
        timer = nil;
    }else{
        [sender setTitle:@"退出频道" forState:UIControlStateNormal];
        GotyeLoginInfo *info = [[GotyeLoginInfo alloc] initWithUserId:_loginId password:nil nickname:_loginName];
        [api setLoginInfo:info];
    
        currentChannel = [[GotyeChannelInfo alloc] initWithToken:@"265087" password:nil];
        [api joinChannel:currentChannel];
    }
}

- (void)exitChannel:(id)sender {
    [api exitChannel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)updateBytes
{
    [self getMemberByUserId:_loginId].sendBytes = [[VoiChannelAPI defaultAPI]getCurrentVoiceTrafficSend];
    [tableViewMemberList reloadData];
}

- (void)selfMute:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"静音"]) {
        [api mute];
        [sender setTitle:@"恢复静音" forState:UIControlStateNormal];
    }
    else {
        [api restore];
        [sender setTitle:@"静音" forState:UIControlStateNormal];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag > 0) {
        // 提升取消管理员
        NSInteger userIndex = actionSheet.tag - 1;
        
        Member *member = [memberList objectAtIndex:userIndex];
        
        switch (buttonIndex) {
            case 0:
                [api kickMember:member.userId];
                break;
            case 1:
            {
                if (!member.silenced) {
                    [api silence:member.userId];
                }
                else {
                    [api unsilence:member.userId];
                }
            }
                break;
                
            case 2:
            {
                switch (member.type) {
                    case President:
                        // can do nothing
                        break;
                        
                    case Administrator:
                        [ api demote:member.userId];
                        break;
                        
                    case Common:
                        [api elevate:member.userId];
                        break;
                        
                    default:
                        break;
                }
            }
                
            default:
                break;
        }
    }
}

//错误异常
- (void)onError:(GotyeErrorType)errorType {
    NSString *str = [NSString stringWithFormat:@"出现了错误：%@ ", [self errorDescription:errorType]];//[NSString alloc];
    
    [self.view makeToast:str];
    
    NSLog(@"%@", str);
    
    if (errorType == ErrorNetworkInvalid) {
        [memberList removeAllObjects];
        [tableViewMemberList reloadData];
    }
}

- (NSString *)errorDescription:(GotyeErrorType)type
{
    switch (type) {
        case ErrorNetworkInvalid:
            return @"ErrorNetworkInvalid";
        case ErrorAppNotExsit:
            return @"ErrorAppNotExsit";
        case ErrorUserNotExsit:
            return @"ErrorUserNotExsit";
        case ErrorInvalidUserID:
            return @"ErrorInvalidUserID";
        case ErrorUserIDInUse:
            return @"ErrorUserIDInUse";
        case ErrorChannelIsFull:
            return @"ErrorChannelIsFull";
        case ErrorServerIsFull:
            return @"ErrorServerIsFull";
        case ErrorPermissionDenial:
            return @"ErrorPermissionDenial";
        case ErrorChannelIsNotExist:
            return @"ErrorChannelIsNotExist";
        case ErrorWrongPassword:
            return @"ErrorWrongPassword";
            
        default:
            return @"ErrorUnknown";
    }
}

//登录 成功/失败
- (void)onLogin:(BOOL)success {
    NSString *str = @"登录成功";//[NSString alloc];

    if (!success) {
        str = @"登录失败";
    }

    [self.view makeToast:str];
}

//退出登录 成功/失败
- (void)onExit:(BOOL)success {
    NSString *str = @"登出成功";//[NSString alloc];
    
    if (!success) {
        str = @"登出失败";
    }
    for(Member *m in memberList)
    {
        if([m.userId isEqualToString:_loginId])
        {
            [memberList removeObject:m];
            return;
        }
    }
    [tableViewMemberList reloadData];
}

/**
 *  获取到频道详情
 *
 *  @param info  频道的详情。（名字等）
 */
- (void)onGetChannelDetail:(GotyeChannelInfo *)info{
    self.title = info.name;
}

//加入频道 成功/失败
- (void)onJoinChannel:(BOOL)success{
    NSString *str = @"加入频道成功";//[NSString alloc];
    
    if (!success) {
        str = @"加入频道失败";
    }
    
    
    NSLog(@"%@", str);
    if(success)
    {
        [api reqChannelDetail:currentChannel];
        [api startTalking];
        Member *selfInfo = [[Member alloc] initWithUserId:_loginId nickname:_loginName];
        [memberList addObject:selfInfo];
//        if (timer == nil || ![timer isValid]) {
//            timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateBytes) userInfo:nil repeats:YES];
//        }
//        [timer fire];

    }

}

//退出频道 成功/失败
- (void)onExitChannel:(BOOL)success{
    NSString *str = @"退出频道成功";//[NSString alloc];
    
    if (!success) {
        str = @"退出频道失败";
    }
    for(Member *m in memberList)
    {
        if([m.userId isEqualToString:_loginId])
        {
            [memberList removeObject:m];
            return;
        }
    }
    [tableViewMemberList reloadData];
}

- (void)onChannelRemoved
{
    NSString *detail = @"频道被删除";
    NSLog(@"%@", detail);
    
    [memberList removeAllObjects];
    [tableViewMemberList reloadData];
    
    [self.view makeToast:detail];
}

- (void)addMember:(NSString *)userId
{
    if(userId==nil)return;
    
    for(Member *m in memberList)
    {
        if([m.userId isEqualToString:userId]/* ||
                                             [m.nickname isEqualToString:info.nickname]*/			)
        {
            return;
        }
    }
    
    Member *member = [[Member alloc] initWithUserId:userId nickname:userId];
    
    [memberList addObject:member];
    [api requestUserNickname:@[userId]];
}

- (void)removeMember:(NSString*)userId
{
    if(userId==nil)return;
    
    for(Member *m in memberList)
    {
        if([m.userId isEqualToString:userId])
        {
            [memberList removeObject:m];
            return;
        }
    }
}

- (void)sensorStateChange:(NSNotification *)notification
{
    if ([[UIDevice currentDevice] proximityState] == YES) {
        NSLog(@"Device is close to user");
        [api setUseSpeaker:NO];
    } else {
        NSLog(@"Device is not close to user");
        [api setUseSpeaker:YES];
    }
}

- (void)onGetUserNickname:(NSDictionary *)userMap
{
    for (NSString *userID in [userMap allKeys]) {
        Member *member = [self getMemberByUserId:userID];
        if (member == nil) {
            continue;
        }
        
        member.nickname = userMap[userID];
    }
    
    [tableViewMemberList reloadData];
}

//获取到频道其他成员
- (void)onGetChannelMember:(NSString *)userId
{
    
    [self addMember:userId];
    
    [tableViewMemberList reloadData];
}

//其他成员退出频道通知
- (void)onRemoveChannelMember:(NSString*)userId{
    
    [self removeMember:userId];
    
    [tableViewMemberList reloadData];
}

//频道中有人开始说话(包含自己)
- (void)onStartTalking:(NSString*)userId{
    NSLog(@"开始说话: %@", userId);
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sensorStateChange:)
                                                 name:UIDeviceProximityStateDidChangeNotification
                                               object:nil];
    
    Member *member = [self getMemberByUserId:userId];
    
    if (member == nil) {
        return;
    }
    
    member.isSpeaking = true;
    
    [tableViewMemberList reloadData];
}

//频道中有人停止说话(包含自己)
- (void)onStopTalking:(NSString*)userId{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    Member *member = [self getMemberByUserId:userId];
    
    if (member == nil) {
        return;
    }
    
    member.isSpeaking = false;
    
    [tableViewMemberList reloadData];
}

//自己禁言|静音状态发生改变
- (void)onMuteStateChanged:(BOOL)muted{
    NSString *str = @"自己静音";
    if (!muted) {
        //    NSString *str = [NSString stringWithFormat:@"%@ 停止说话", userId];//[NSString alloc];
        str = @"自己取消静音";
        
    }
    NSLog(@"%@", str);
    //    [self.view makeToast:str];
}

//频道中有人被管理员 禁言/取消禁言(包括自己)
- (void)onSilencedStateChanged:(BOOL)silenced with:(NSString*)userId{
    
    NSLog(@"用户 %@ 禁言状态 %d", userId, silenced);
    
    Member *member = [self getMemberByUserId:userId];
    
    if (member == nil) {
        return;
    }
    
    member.silenced = silenced;
    
    [tableViewMemberList reloadData];
}

//通知：获取到频道成员类型表
//typeList中key为成员userId，value为封装了MemberType的NSNumber类型; 不在此字典中的其他成员均为普通成员.
- (void)notifyChannelMemberTypes:(NSDictionary*)typeList{
    NSLog(@"频道成员类型：%@", [typeList debugDescription]);
    for ( Member *member in memberList) {
        if ([[typeList allKeys] containsObject:member.userId]) {
            NSString *type = [typeList objectForKey:member.userId];
            member.type = (MemberType) [type integerValue];
        }
    }
    
    [tableViewMemberList reloadData];
}


#pragma mark - TabelView delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return memberList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *audio, *role;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Member *member = [memberList objectAtIndex:indexPath.row];
    
    if (member.silenced) {
        audio = @"取消禁言";
    }
    else
        audio = @"禁言";
    
    if (member.type == President) {
        role = nil;
    }
    else if (member.type == Administrator) {
        role = @"取消管理员";
    }
    else if (member.type == Common) {
        role = @"提升管理员";
    }
    
    NSString *kick = @"踢出用户";
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles: kick, audio, role, nil];
    
    sheet.tag = 1 + indexPath.row;
    
    [sheet showInView:self.view];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simple = @"simple";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simple];
    if(cell==nil)
    {
        cell = [[UITableViewCell alloc] init];
    }
    Member *member =memberList[indexPath.row];
    cell.textLabel.text = member.nickname.length > 0 ? member.nickname : member.userId;
    if (member.silenced) {
        cell.textLabel.text = [cell.textLabel.text stringByAppendingString: @"[禁言]"];
    }
    
    if (member.isSpeaking) {
        cell.textLabel.textColor = [UIColor greenColor];
        cell.textLabel.text = [cell.textLabel.text stringByAppendingString: @"[说话中]"];
    }
    
    if (member.type == Administrator) {
        cell.textLabel.text = [cell.textLabel.text stringByAppendingString: @"[管理员]"];
    } else if (member.type == President) {
        cell.textLabel.text = [cell.textLabel.text stringByAppendingString: @"[会长]"];
    }
    
    if (member.sendBytes > 0) {
        NSString *sendBytes = [NSString stringWithFormat:@"[%lu bytes]", (unsigned long)member.sendBytes];
        cell.textLabel.text = [cell.textLabel.text stringByAppendingString: sendBytes];
    }
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    
    return cell;
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
