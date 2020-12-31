//
//  GeeGlanceMatchingResult.h
//  GeeGlanceSDK
//
//  Created by noctis on 2020/12/31.
//  Copyright © 2020 com.geetest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeeGlanceMatchResult.h"
#import "GeeGlanceExtraInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface GeeGlanceMatchingResult : NSObject

// 200 - 匹配正常，500 - 匹配出错，请根据 extraInfo 中的 error 查看具体出错信息
@property (nonatomic, assign) NSInteger status;
// 匹配原文
@property (nonatomic, copy) NSString *originContent;
// 匹配到的敏感字符，若为空，说明无敏感字符
@property (nonatomic, strong) NSMutableArray<GeeGlanceMatchResult *> *results;
// 额外信息，包括 merchantId、 SDK 版本号等辅助定位问题的字段
@property (nonatomic, strong) GeeGlanceExtraInfo *extraInfo;

@end

NS_ASSUME_NONNULL_END
