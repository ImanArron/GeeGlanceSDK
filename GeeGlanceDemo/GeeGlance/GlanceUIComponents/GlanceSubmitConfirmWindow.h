//
//  SubmitConfirmWindow.h
//  Glance
//
//  Created by noctis on 2020/9/1.
//  Copyright © 2020 com.geetest. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SubmitAction)(void);
typedef void(^HandleProtocolBlock)(NSURL *URL);

@interface GlanceSubmitConfirmWindow : UIView

- (instancetype)initWithBaseView:(UIView *)baseView
                attributedString:(NSAttributedString * _Nullable)attrStr
                   confirmAction:(SubmitAction)confirmAction
                    cancelAction:(SubmitAction)cancelAction
             handleProtocolBlock:(HandleProtocolBlock)handleProtocolBlock;

- (void)showWindow;
- (void)hideWindow;

@end

NS_ASSUME_NONNULL_END
