/*
 *  BMKShareUrlSearchOption.h
 *  BMapKit
 *
 *  Copyright 2014 Baidu Inc. All rights reserved.
 *
 */

#import "BMKTypes.h"
/// poi详情短串分享检索信息类
@interface BMKPoiDetailShareURLOption : NSObject
{
    NSString        *_uid;
}
///poi的uid
@property (nonatomic, retain) NSString *uid;

@end

///反geo短串分享检索信息类
@interface BMKLocationShareURLOption : NSObject {
    NSString                *_name;
    NSString                *_snippet;
    CLLocationCoordinate2D  _location;
}
///名称
@property (nonatomic, retain) NSString *name;
///通过短URL调起客户端时作为附加信息显示在名称下面
@property (nonatomic, retain) NSString *snippet;
///经纬度
@property (nonatomic, assign) CLLocationCoordinate2D location;
@end

