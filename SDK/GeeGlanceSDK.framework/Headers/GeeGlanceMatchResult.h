//
//  GeeGlanceMatchResult.h
//  GeeGlance
//
//  Created by noctis on 2020/9/7.
//  Copyright © 2020 com.geetest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GeeGlanceMatchResultCategory) {
    GeeGlanceMatchResultCategoryNone,                  // 无类别
    GeeGlanceMatchResultCategoryReactionary,           // 反动
    GeeGlanceMatchResultCategoryLivelihood,            // 民生
    GeeGlanceMatchResultCategoryPornography,           // 色情
    GeeGlanceMatchResultCategoryAdertisement,          // 广告
    GeeGlanceMatchResultCategoryPolitics,              // 涉政
    GeeGlanceMatchResultCategoryViolent,               // 暴恐
    GeeGlanceMatchResultCategoryCorruption,            // 贪腐
    GeeGlanceMatchResultCategoryOther,                 // 其他
};

@interface GeeGlanceMatchResult : NSObject

@property (nonatomic, assign) NSInteger startLocation;
@property (nonatomic, assign) NSInteger endLocation;
@property (nonatomic, assign) NSRange range;
// 类别
@property (nonatomic, copy, nullable) NSString *resultCategory;
// 等级
@property (nonatomic, copy, nullable) NSString *riskLevel;
// 违规词
@property (nonatomic, copy, nullable) NSString *sensitiveWord;

- (instancetype)initWithStartLocation:(NSInteger)startLocation
                          endLocation:(NSInteger)endLocation;

- (instancetype)initWithStartLocation:(NSInteger)startLocation
                          endLocation:(NSInteger)endLocation
                       resultCategory:(NSString * _Nullable)resultCategory
                            riskLevel:(NSString * _Nullable)riskLevel;

- (instancetype)initWithStartLocation:(NSInteger)startLocation
                          endLocation:(NSInteger)endLocation
                       resultCategory:(NSString * _Nullable)resultCategory
                            riskLevel:(NSString * _Nullable)riskLevel
                        sensitiveWord:(NSString * _Nullable)sensitiveWord;

@end

NS_ASSUME_NONNULL_END
