//
//  DistributeSceneController.m
//  Glance
//
//  Created by noctis on 2020/9/2.
//  Copyright © 2020 com.geetest. All rights reserved.
//

#import "DistributeSceneController.h"
#import "ColorUtil.h"
#import "Masonry.h"
#import "GlanceButton.h"
#import <GeeGlanceSDK/GeeGlanceSDK.h>

@interface DistributeSceneController () <GeeGlanceTextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *navigationView;
@property (weak, nonatomic) IBOutlet GlanceButton *backButton;
@property (weak, nonatomic) IBOutlet GlanceButton *distributeButton;

@property (weak, nonatomic) IBOutlet GeeGlanceTextView *editTextView;

@property (strong, nonatomic) UILabel *hintLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;

@end

@implementation DistributeSceneController

// MARK: View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupViews];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)setupViews {
    UIView *navigationSeperator = [[UIView alloc] init];
    navigationSeperator.backgroundColor = [ColorUtil colorFromHexString:@"#DDDDDD"];
    [self.navigationView addSubview:navigationSeperator];
    [navigationSeperator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.navigationView);
        make.height.mas_equalTo(0.5);
    }];
    
    self.editTextView.placeholder = @"在这里违规的内容将会被直接识别并展示，请输入您的文章内容。";
    self.editTextView.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.85];
    self.editTextView.font = [UIFont fontWithName:@"PingFang SC" size:15];
    self.editTextView.delegate = self;
    self.editTextView.sceneKey = @"ArticlePublishing";
    self.editTextView.sceneType = GeeGlanceSceneTypeLong;
    
    if (UIScreen.mainScreen.bounds.size.height <= 667) {
        self.textViewHeightConstraint.constant = 260;
    }
}

// MARK: Actions

- (IBAction)backAction:(id)sender {
    self.transitioningDelegate = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)distributeAction:(id)sender {
    [self.view endEditing:YES];
    __weak typeof(self) wself = self;
    [GTProgressHUD showLoadingHUDWithMessage:@"智能匹配中…"];
    [self.editTextView submitWithCompletionHandler:^(NSString * _Nonnull text, NSMutableArray<GeeGlanceMatchResult *> * _Nonnull results) {
        [GTProgressHUD hideAllHUD];
        [wself confirmSendContent:text matchResults:results];
    }];
}

- (void)confirmSendContent:(NSString *)content matchResults:(NSMutableArray<GeeGlanceMatchResult *> *)matchResults {
    if (matchResults.count > 0) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"确定提交" message:@"您输入的内容中包括了部分平台违规内容，继续提交可能会被审查系统过滤。建议您进行修改后发表" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"依然发送" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self distributeArticle];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"返回修改" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.editTextView becomeFirstResponder];
        }];
        [controller addAction:confirmAction];
        [controller addAction:cancelAction];
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        if (self.editTextView.text.length > 0) {
            [self distributeArticle];
        }
    }
}

- (void)distributeArticle {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"发布成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.editTextView.text = nil;
        self.editTextView.attributedText = nil;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.transitioningDelegate = nil;
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }];
    [controller addAction:doneAction];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)tapAction:(UITapGestureRecognizer *)tapGesture {
    [self.editTextView resignFirstResponder];
}

// MARK: GeeGlanceTextViewDelegate

- (void)textView:(GeeGlanceTextView *)textView didGlanceStatusChanged:(GeeGlanceTextViewStatus)glanceStatus {
    if (textView.matchResults.count > 0) {
        [self showHintLabel];
    } else {
        [self hideHintLabel];
    }
}

// MARK: Hint Label

- (UILabel *)hintLabel {
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.backgroundColor = [UIColor clearColor];
        _hintLabel.hidden = YES;
        
        NSMutableAttributedString *mutableAttrStr = [[NSMutableAttributedString alloc] init];
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage imageNamed:@"Group 721"];
        attachment.bounds = CGRectMake(0, -2.5, 12, 12);
        [mutableAttrStr appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        
        NSAttributedString *hintAttrStr = [[NSAttributedString alloc] initWithString:@"  监测到有不和谐内容，建议修改" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:11], NSForegroundColorAttributeName : [ColorUtil colorFromHexString:@"#929292"]}];
        [mutableAttrStr appendAttributedString:hintAttrStr];
        
        _hintLabel.attributedText = [mutableAttrStr copy];
    }
    return _hintLabel;
}

- (void)showHintLabel {
    if (!self.hintLabel.superview) {
        [self.view addSubview:self.hintLabel];
        [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.view).offset(-16);
            make.top.equalTo(self.editTextView.mas_bottom).offset(10);
        }];
    }
    
    if (self.hintLabel.isHidden) {
        [UIView animateWithDuration:0.3 animations:^{
            self.hintLabel.hidden = NO;
        }];
    }
}

- (void)hideHintLabel {
    if (!self.hintLabel.isHidden) {
        [UIView animateWithDuration:0.3 animations:^{
            self.hintLabel.hidden = YES;
        }];
    }
}

@end
