//
//  GeeGlanceConstants.h
//  GeeGlanceSDK
//
//  Created by noctis on 2020/10/22.
//  Copyright © 2020 com.geetest. All rights reserved.
//

#ifndef GeeGlanceConstants_h
#define GeeGlanceConstants_h

// MARK: SceneType

typedef NS_ENUM(NSInteger, GeeGlanceSceneType) {
    GeeGlanceSceneTypeSuperShort = 1,      // 超短文本(昵称、群名称等)
    GeeGlanceSceneTypeShort,               // 短文本(弹幕等)
    GeeGlanceSceneTypeMedium,              // 中等文本(评论等)
    GeeGlanceSceneTypeLong                 // 长文本(文章发布等)
};

// MARK: SDK Version

static NSString * const GeeGlanceSDKVersion = @"1.1.0";

#endif /* GeeGlanceConstants_h */
