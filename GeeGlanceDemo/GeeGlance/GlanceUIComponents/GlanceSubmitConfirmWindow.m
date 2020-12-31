//
//  SubmitConfirmWindow.m
//  Glance
//
//  Created by noctis on 2020/9/1.
//  Copyright © 2020 com.geetest. All rights reserved.
//

#import "GlanceSubmitConfirmWindow.h"
#import "ColorUtil.h"
#import "Masonry.h"

@interface GlanceSubmitConfirmWindow () <UITextViewDelegate>

@property (nonatomic, weak) UIView *baseView;

@property (nonatomic, copy) NSAttributedString *attrStr;

@property (nonatomic, strong) UITextView *protocolView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UITextView *violationContentTextView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, copy) SubmitAction confirmAction;
@property (nonatomic, copy) SubmitAction cancelAction;
@property (nonatomic, copy) HandleProtocolBlock handleProtocolBlock;

@property (nonatomic, assign) CGFloat windowHeight;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation GlanceSubmitConfirmWindow

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

// MARK: Dealloc

- (void)dealloc {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    if (self.superview) {
        [self removeFromSuperview];
    }
    
    if (self.tapGesture) {
        [self.baseView removeGestureRecognizer:self.tapGesture];
    }
}

// MARK: Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithBaseView:(UIView *)baseView
                attributedString:(NSAttributedString * _Nullable)attrStr
                   confirmAction:(SubmitAction)confirmAction
                    cancelAction:(SubmitAction)cancelAction
             handleProtocolBlock:(HandleProtocolBlock)handleProtocolBlock {
    self = [super init];
    if (self) {
        self.baseView = baseView;
        self.attrStr = attrStr;
        self.confirmAction = confirmAction;
        self.cancelAction = cancelAction;
        self.handleProtocolBlock = handleProtocolBlock;
        [self setupSubViews];
    }
    return self;
}

// MARK: Setup

- (void)setupSubViews {
    self.windowHeight = 0;
    self.hidden = YES;
    self.backgroundColor = [UIColor whiteColor];
    
    CGFloat horizontalMargin = 16;
    [self addSubview:self.protocolView];
    CGSize protocolSize = [self.protocolView sizeThatFits:CGSizeMake(UIScreen.mainScreen.bounds.size.width - 2 * horizontalMargin, CGFLOAT_MAX)];
    [self.protocolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(horizontalMargin);
        make.trailing.equalTo(self).offset(-horizontalMargin);
        make.bottom.equalTo(self).offset(-40);
        make.height.mas_equalTo(protocolSize.height);
    }];
    
    self.windowHeight += (40 + protocolSize.height);
    
    [self addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(horizontalMargin);
        make.bottom.equalTo(self.protocolView.mas_top).offset(-99);
        make.height.mas_equalTo(33);
        make.trailing.equalTo(self.mas_centerX).offset(-8);
    }];
    
    [self addSubview:self.confirmButton];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-horizontalMargin);
        make.centerY.equalTo(self.cancelButton);
        make.height.mas_equalTo(33);
        make.leading.equalTo(self.mas_centerX).offset(8);
    }];
    
    self.windowHeight += (33 + 99);
    
    [self addSubview:self.hintLabel];
    CGSize hintSize = [self.hintLabel sizeThatFits:CGSizeMake(UIScreen.mainScreen.bounds.size.width - 2 * horizontalMargin, CGFLOAT_MAX)];
    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(horizontalMargin);
        make.trailing.equalTo(self).offset(-horizontalMargin);
        make.bottom.equalTo(self.cancelButton.mas_top).offset(-23);
        make.height.mas_equalTo(hintSize.height);
    }];
    
    self.windowHeight += (23 + hintSize.height);
    
    if (self.attrStr.length > 0) {
        self.violationContentTextView.attributedText = self.attrStr;
        CGSize violationSize = [self.violationContentTextView sizeThatFits:CGSizeMake(UIScreen.mainScreen.bounds.size.width - 2 * horizontalMargin, CGFLOAT_MAX)];
        [self addSubview:self.violationContentTextView];
        [self.violationContentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(horizontalMargin);
            make.trailing.equalTo(self).offset(-horizontalMargin);
            make.bottom.equalTo(self.hintLabel.mas_top).offset(-21);
            make.height.mas_equalTo(violationSize.height);
        }];
        
        self.windowHeight += (21 + violationSize.height);
        
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.violationContentTextView.mas_top).offset(-40);
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(horizontalMargin);
        }];
        
        self.windowHeight += (horizontalMargin + 40 + 20);
    } else {
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.hintLabel.mas_top).offset(-40);
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(horizontalMargin);
        }];
        
        self.windowHeight += (horizontalMargin + 40 + 20);
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.windowHeight) byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, self.windowHeight);
    layer.path = path.CGPath;
    self.layer.mask = layer;
}

// MARK: Show & Hide

- (void)showWindow {
    if (!self.superview && self.baseView) {
        [self.baseView addSubview:self];
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.baseView);
            make.height.mas_equalTo(self.windowHeight);
            make.bottom.equalTo(self.baseView).offset(self.windowHeight);
        }];
        
        [self.baseView layoutIfNeeded];
    }
    
    if (self.isHidden) {
        if (self.baseView && !self.maskView.superview) {
            [self.baseView insertSubview:self.maskView belowSubview:self];
            [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.baseView);
            }];
        }
        
        self.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.baseView).offset(0);
            }];
        } completion:^(BOOL finished) {
            
        }];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWindowAction:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.cancelsTouchesInView = NO;
        [self.baseView addGestureRecognizer:tapGesture];
        self.tapGesture = tapGesture;
    }
}

- (void)hideWindow {
    if (!self.isHidden) {
        [UIView animateWithDuration:0.3 animations:^{
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.baseView).offset(self.windowHeight);
            }];
        } completion:^(BOOL finished) {
            self.hidden = YES;
        }];
        
        if (self.tapGesture) {
            [self.baseView removeGestureRecognizer:self.tapGesture];
        }
        
        [self.maskView removeFromSuperview];
        self.maskView = nil;
    }
}

// MARK: Actions

- (void)cancelAction:(UIButton *)button {
    [self hideWindow];
    if (self.cancelAction) {
        self.cancelAction();
    }
}

- (void)confirmAction:(UIButton *)button {
    [self hideWindow];
    if (self.confirmAction) {
        self.confirmAction();
    }
}

- (void)tapWindowAction:(UITapGestureRecognizer *)tapGesture {
    [self hideWindow];
}

// MARK: UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if (nil != URL) {
        if (self.handleProtocolBlock) {
            self.handleProtocolBlock(URL);
        }
    }
    return NO;
}

// MARK: Getter

- (UITextView *)protocolView {
    if (!_protocolView) {
        _protocolView = [[UITextView alloc] init];
        _protocolView.backgroundColor = [UIColor clearColor];
        NSAttributedString *startAttrStr = [[NSAttributedString alloc] initWithString:@"阅读并同意" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:11], NSForegroundColorAttributeName : [ColorUtil colorFromHexString:@"#666666"]}];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithAttributedString:startAttrStr];
        NSArray *protocols = @[@"《隐私政策》", @"《网络文明用语准则》", @"《阳光行为规范》"];
        for (NSString *protocol in protocols) {
            NSAttributedString *tmpAttrStr = [[NSAttributedString alloc] initWithString:protocol attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:11], NSForegroundColorAttributeName : [ColorUtil colorFromHexString:@"#4271DD"], NSLinkAttributeName : @"https://www.geetest.com"}];
            [attrStr appendAttributedString:tmpAttrStr];
        }
        _protocolView.attributedText = [attrStr copy];
        _protocolView.editable = NO;
        _protocolView.scrollEnabled = NO;
        _protocolView.delegate = self;
    }
    return _protocolView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:@"返回修改" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _cancelButton.backgroundColor = [ColorUtil colorFromHexString:@"#3170E5"];
        [_cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.layer.masksToBounds = YES;
        _cancelButton.layer.cornerRadius = 4;
    }
    return _cancelButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:@"依然发送" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[ColorUtil colorFromHexString:@"#1A1A1A"] forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _confirmButton.backgroundColor = [ColorUtil colorFromHexString:@"#D5D7DD"];
        [_confirmButton addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.layer.masksToBounds = YES;
        _confirmButton.layer.cornerRadius = 4;
    }
    return _confirmButton;
}

- (UILabel *)hintLabel {
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.backgroundColor = [UIColor clearColor];
        _hintLabel.textColor = UIColor.blackColor;
        _hintLabel.font = [UIFont systemFontOfSize:13];
        _hintLabel.numberOfLines = 0;
        _hintLabel.text = @"您输入的内容中包括了部分平台违规内容，继续提交可能会被审查系统过滤。建议您进行修改后发表！";
    }
    return _hintLabel;
}

- (UITextView *)violationContentTextView {
    if (!_violationContentTextView) {
        _violationContentTextView = [[UITextView alloc] init];
        _violationContentTextView.backgroundColor = [ColorUtil colorFromHexString:@"F7F7F7"];
        _violationContentTextView.contentInset = UIEdgeInsetsMake(14, 16, 14, 16);
        _violationContentTextView.editable = NO;
        _violationContentTextView.scrollEnabled = NO;
        _violationContentTextView.layer.masksToBounds = YES;
        _violationContentTextView.layer.cornerRadius = 4;
    }
    return _violationContentTextView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = UIColor.blackColor;
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"确认提交？";
    }
    return _titleLabel;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.45];
    }
    return _maskView;
}

@end
