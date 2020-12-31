//
//  ColorUtil.m
//  Glance
//
//  Created by noctis on 2020/8/28.
//  Copyright © 2020 com.geetest. All rights reserved.
//

#import "ColorUtil.h"

@implementation ColorUtil

+ (UIColor *)colorFromHexString:(const NSString *)hexString {
    return [ColorUtil colorFromHexString:hexString alpha:1.0];
}

+ (UIColor *)colorFromHexString:(const NSString *)hexString alpha:(CGFloat)alpha {
    if ([hexString isKindOfClass:[NSString class]] && hexString.length > 0) {
        NSString *tmpHexString = hexString.copy;
        if ([tmpHexString hasPrefix:@"#"]) {
            tmpHexString = [tmpHexString substringFromIndex:[@"#" length]];
        }
        
        if (tmpHexString.length > 0) {
            if (tmpHexString.length >= 6) {      // 大于6位，取前6位
                tmpHexString = [tmpHexString substringToIndex:6];
            } else {                             // 不足6位，前面补0
                while (tmpHexString.length < 6) {
                    tmpHexString = [@"0" stringByAppendingString:tmpHexString];
                }
            }
            
            NSRange range = NSMakeRange(0, 2);
            NSString *rString = [tmpHexString substringWithRange:range];
            range.location = range.location + 2;
            NSString *gString = [tmpHexString substringWithRange:range];
            range.location = range.location + 2;
            NSString *bString = [tmpHexString substringWithRange:range];
            // 取三种颜色值
            unsigned int r, g, b;
            [[NSScanner scannerWithString:rString] scanHexInt:&r];
            [[NSScanner scannerWithString:gString] scanHexInt:&g];
            [[NSScanner scannerWithString:bString] scanHexInt:&b];

            return [UIColor colorWithRed:((float)r / 255.0)
                                   green:((float)g / 255.0)
                                    blue:((float)b / 255.0)
                                   alpha:alpha];
        }
    }
    
    return UIColor.clearColor;
}

@end
