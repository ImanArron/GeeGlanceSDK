//
//  GeeGlanceManager.h
//  GeeGlance
//
//  Created by noctis on 2020/8/27.
//  Copyright © 2020 com.geetest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GeeGlanceMatchResult.h"
#import "GeeGlanceExtraInfo.h"
#import "GeeGlanceConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface GeeGlanceManager : NSObject

// MARK: Initialize Params

/**
 @abstract 将 merchantId 传入给 SDK，该参数为必传参数
 
 @param merchantId 商户 ID，merchantId 通过后台注册获得，从极验后台获取该 merchantId，merchantId 需与 bundleId 配套
 */
+ (void)registerWithMerchantId:(NSString * _Nonnull)merchantId;

/**
 @abstract 设置使用场景 key，该参数为可选参数
 
 @param sceneKey 使用场景 key
 
 @discussion 推荐在只有单个识别场景时使用该方法设置场景 key，后续通过 `matchesInContent:completionHandler:` 方法进行内容识别
 */
+ (void)setSceneKey:(NSString * _Nullable)sceneKey;

/**
 @abstract 设置使用场景类型，该参数为可选参数
 
 @param sceneType 使用场景类型
 
 @discussion 当前场景类型有 4 种：
             GeeGlanceSceneTypeSuperShort - 超短文本(昵称、群名称等)
             GeeGlanceSceneTypeShort - 短文本(弹幕等)
             GeeGlanceSceneTypeMedium - 中等文本(评论等)
             GeeGlanceSceneTypeLong - 长文本(文章发布等)
 
             推荐在只有单个识别场景时使用该方法设置场景 type，后续通过 `matchesInContent:completionHandler:` 方法进行内容识别
 */
+ (void)setSceneType:(GeeGlanceSceneType)sceneType;

/**
 @abstract 设置 uid，该参数为可选参数
 
 @param uid 用户 id
 */
+ (void)setUid:(NSString * _Nullable)uid;

// MARK: Log

/**
 @abstract 设置日志开关，默认关闭，不打印日志
 
 @param enableLog YES - 打印日志，NO - 不打印日志
 */
+ (void)enableLog:(BOOL)enableLog;

// MARK: Match

/**
 @abstract 匹配字符串中的敏感词
 
 @param content 待匹配的字符串
 @param completionHandler 匹配结果
 
 @discussion 匹配结果中包含三个字段
             results - 匹配结果，包括匹配到的敏感词，敏感词在整段文本中的起始位置，敏感词类别、违规等级
             originContent - 匹配的原文
             extraInfo - 额外信息，包括传入的 merchantId、匹配任务的 taskId、sdk、应用、系统等版本号、机型，匹配出错时，error 中有具体错误描述信息
 */
+ (void)matchesInContent:(NSString * _Nullable)content
       completionHandler:(void(^)(NSMutableArray<GeeGlanceMatchResult *> *results, NSString *originContent, GeeGlanceExtraInfo *extraInfo))completionHandler;

/**
 @abstract 匹配字符串中的敏感词
 
 @param content 待匹配的字符串
 @param config 匹配场景配置，包括配置场景 key 和场景 type
 @param completionHandler 匹配结果
 
 @discussion 匹配结果中包含三个字段
             results - 匹配结果，包括匹配到的敏感词，敏感词在整段文本中的起始位置，敏感词类别、违规等级
             originContent - 匹配的原文
             extraInfo - 额外信息，包括传入的 merchantId、匹配任务的 taskId、sdk、应用、系统等版本号、机型，匹配出错时，error 中有具体错误描述信息
 */
+ (void)matchesInContent:(NSString * _Nullable)content
              withConfig:(GeeGlanceConfig * _Nullable)config
       completionHandler:(void(^)(NSMutableArray<GeeGlanceMatchResult *> *results, NSString *originContent, GeeGlanceExtraInfo *extraInfo))completionHandler;

// MARK: SDK Version

/**
 @abstract 获取 SDK 版本号
 
 @return SDK 版本号
 */
+ (NSString * _Nonnull)sdkVersion;

@end

NS_ASSUME_NONNULL_END
