//
//  GeeGlanceExtraInfo.h
//  GeeGlance
//
//  Created by noctis on 2020/10/12.
//  Copyright © 2020 com.geetest. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const GeeGlanceClientType;

@interface GeeGlanceExtraInfo : NSObject

- (instancetype)initWithMerchantId:(NSString * _Nonnull)merchantId taskId:(NSString * _Nonnull)taskId;
- (instancetype)initWithMerchantId:(NSString * _Nonnull)merchantId taskId:(NSString * _Nonnull)taskId error:(NSError * _Nullable)error NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, copy, readonly, nonnull) NSString *taskId;
@property (nonatomic, copy, readonly, nonnull) NSString *merchantId;
@property (nonatomic, copy, readonly, nonnull) NSString *clientType;
@property (nonatomic, copy, readonly, nonnull) NSString *sdkVersion;
@property (nonatomic, copy, readonly, nonnull) NSString *systemVersion;
@property (nonatomic, copy, readonly, nonnull) NSString *bundleShortVersion;
@property (nonatomic, copy, readonly, nonnull) NSString *bundleVersion;
@property (nonatomic, copy, readonly, nonnull) NSString *deviceModel;
@property (nonatomic, strong, readonly, nullable) NSError *error;

@end

NS_ASSUME_NONNULL_END
