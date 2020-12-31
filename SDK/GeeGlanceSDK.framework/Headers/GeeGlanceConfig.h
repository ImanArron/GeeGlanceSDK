//
//  GeeGlanceConfig.h
//  GeeGlanceSDK
//
//  Created by noctis on 2020/11/16.
//  Copyright © 2020 com.geetest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeeGlanceConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface GeeGlanceConfig : NSObject

@property (nonatomic, copy, nonnull, readonly) NSString *sceneKey;
@property (nonatomic, assign, readonly) GeeGlanceSceneType sceneType;

- (instancetype)initWithSceneKey:(NSString * _Nullable)sceneKey
                       sceneType:(GeeGlanceSceneType)sceneType NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
