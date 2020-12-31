//
//  ColorUtil.h
//  Glance
//
//  Created by noctis on 2020/8/28.
//  Copyright © 2020 com.geetest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ColorUtil : NSObject

+ (UIColor *)colorFromHexString:(const NSString *)hexString;
+ (UIColor *)colorFromHexString:(const NSString *)hexString alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
