//
//  GlanceButton.m
//  Glance
//
//  Created by noctis on 2020/8/31.
//  Copyright © 2020 com.geetest. All rights reserved.
//

#import "GlanceButton.h"

@implementation GlanceButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    CGFloat widthDelta = MAX(30, 0);
    CGFloat heightDelta = MAX(30, 0);
    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    return CGRectContainsPoint(bounds, point);
}

@end
