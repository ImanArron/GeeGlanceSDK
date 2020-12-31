//
//  GeeGlanceErrorInfo.h
//  GeeGlanceSDK
//
//  Created by noctis on 2020/10/22.
//  Copyright © 2020 com.geetest. All rights reserved.
//

#ifndef GeeGlanceErrorInfo_h
#define GeeGlanceErrorInfo_h

static NSString * const GeeGlanceErrorMetadata   = @"metadata";

static NSString * const GeeGlanceErrorCode_20101 = @"-20101";              // merchantId 无效
static NSString * const GeeGlanceErrorDesc_20101 = @"Invalid merchant id.";

static NSString * const GeeGlanceErrorCode_20102 = @"-20102";              // scene key 无效
static NSString * const GeeGlanceErrorDesc_20102 = @"Invalid scene key.";

static NSString * const GeeGlanceErrorCode_20103 = @"-20103";              // scene type 无效
static NSString * const GeeGlanceErrorDesc_20103 = @"Invalid scene type.";

static NSString * const GeeGlanceErrorCode_20104 = @"-20104";              // 服务端校验失败
static NSString * const GeeGlanceErrorDesc_20104 = @"Check failed from server.";

#endif /* GeeGlanceErrorInfo_h */
