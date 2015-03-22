//
//  ChannelViewController.h
//  Demo
//
//  Created by nichalos on 15/3/18.
//  Copyright (c) 2015年 artron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VoiChannelAPI.h"

@interface Member : NSObject

@property (copy, nonatomic) NSString *userId;//用户ID
@property (copy, nonatomic) NSString *nickname; //用户昵称
@property (assign, nonatomic) BOOL silenced;//是否被禁言
@property (assign, nonatomic) BOOL isSpeaking; //是否正在说话
@property (assign, nonatomic) MemberType type;
@property (assign, nonatomic) NSUInteger sendBytes;

- (id)initWithUserId:(NSString*)userId nickname:(NSString*)nickname;

@end

@interface ChannelViewController : UIViewController<VoiChannelAPIDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>

@property (strong, nonatomic)NSString *loginId;
@property (strong, nonatomic)NSString *loginName;
@property (strong, nonatomic)UICollectionView *collectionView;
@end
