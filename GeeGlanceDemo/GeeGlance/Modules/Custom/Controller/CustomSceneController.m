//
//  CustomSceneController.m
//  Glance
//
//  Created by noctis on 2020/11/17.
//  Copyright © 2020 com.geetest. All rights reserved.
//

#import "CustomSceneController.h"
#import "ColorUtil.h"
#import "Masonry.h"
#import "GlanceButton.h"
#import <GeeGlanceSDK/GeeGlanceSDK.h>

@interface CustomSceneController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *navigationView;
@property (weak, nonatomic) IBOutlet GlanceButton *backButton;
@property (weak, nonatomic) IBOutlet GlanceButton *distributeButton;
@property (weak, nonatomic) IBOutlet UITextView *editTextView;

@property (nonatomic, copy) NSDictionary *typingAttributes;

@end

@implementation CustomSceneController

// MARK: ViewLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupViews];
    self.typingAttributes = self.editTextView.typingAttributes;
}

- (void)setupViews {
    UIView *navigationSeperator = [[UIView alloc] init];
    navigationSeperator.backgroundColor = [ColorUtil colorFromHexString:@"#DDDDDD"];
    [self.navigationView addSubview:navigationSeperator];
    [navigationSeperator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.navigationView);
        make.height.mas_equalTo(0.5);
    }];
    
    self.editTextView.delegate = self;
}

// MARK: Actions

- (IBAction)backAction:(id)sender {
    self.transitioningDelegate = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)distributeAction:(id)sender {
    [self.view endEditing:YES];
    if (self.editTextView.text.length > 0) {
        __weak typeof(self) wself = self;
        [GTProgressHUD showLoadingHUDWithMessage:@"智能匹配中…"];
        // 开始匹配
        NSString *sceneKey = [[NSUserDefaults standardUserDefaults] valueForKey:@"CustomSceneKey"];
        if (nil == sceneKey || 0 == sceneKey.length) {
            sceneKey = @"Custom";
        }
        NSString *typeString = [[NSUserDefaults standardUserDefaults] valueForKey:@"CustomSceneType"];
        GeeGlanceSceneType sceneType = GeeGlanceSceneTypeLong;
        if (typeString.length > 0) {
            sceneType = [typeString integerValue];
        }
        GeeGlanceConfig *config = [[GeeGlanceConfig alloc] initWithSceneKey:sceneKey sceneType:sceneType];
        [GeeGlanceManager matchesInContent:self.editTextView.text withConfig:config completionHandler:^(NSMutableArray<GeeGlanceMatchResult *> * _Nonnull results, NSString * _Nonnull originContent, GeeGlanceExtraInfo * _Nonnull extraInfo) {
            [wself finishMatching:results originContent:originContent extraInfo:extraInfo];
        }];
    } else {
        [GTProgressHUD showToastWithMessage:@"请输入要识别的内容"];
    }
}

- (void)finishMatching:(NSMutableArray<GeeGlanceMatchResult *> *)results originContent:(NSString *)originContent extraInfo:(GeeGlanceExtraInfo *)extraInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        [GTProgressHUD hideAllHUD];
        NSString *text = self.editTextView.text;
        NSInteger textLen = text.length;
        NSRange selectRange = self.editTextView.selectedRange;
        NSDictionary *typingAttributes = self.typingAttributes;
        if (results.count > 0) {
            UIColor *color = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.16];
            NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithString:text];
            NSInteger lastStart = 0;
            for (NSInteger i = 0; i < results.count; i++) {
                GeeGlanceMatchResult *matchResult = results[i];
                NSInteger start = matchResult.startLocation;
                NSInteger end = matchResult.endLocation;
                NSMutableDictionary *masAttibutes = [NSMutableDictionary dictionary];
                if (start >= 0 && end <= textLen && end > start) {
                    masAttibutes[NSBackgroundColorAttributeName] = color;
                    masAttibutes[NSUnderlineColorAttributeName] = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.64];
                    masAttibutes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleThick);
                    if (typingAttributes[NSFontAttributeName]) {
                        masAttibutes[NSFontAttributeName] = typingAttributes[NSFontAttributeName];
                    }
                    if (typingAttributes[NSParagraphStyleAttributeName]) {
                        masAttibutes[NSParagraphStyleAttributeName] = typingAttributes[NSParagraphStyleAttributeName];
                    }
                    [mas addAttributes:masAttibutes range:NSMakeRange(start, end - start)];
                }
                if (start > lastStart && start - lastStart <= textLen && lastStart < textLen && typingAttributes.count > 0) {
                    [mas addAttributes:typingAttributes range:NSMakeRange(lastStart, start - lastStart)];
                }
                lastStart = end;
            }
            
            if (lastStart < text.length && typingAttributes.count > 0) {
                [mas addAttributes:typingAttributes range:NSMakeRange(lastStart, text.length - lastStart)];
            }
            
            self.editTextView.attributedText = [mas copy];
            self.editTextView.selectedRange = selectRange;
            
        } else {
            [GTProgressHUD showToastWithMessage:@"未匹配到敏感词"];
            if (typingAttributes.count > 0 && textLen > 0) {
                NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithString:text];
                [mas addAttributes:typingAttributes range:NSMakeRange(0, textLen)];
                self.editTextView.attributedText = [mas copy];
                self.editTextView.selectedRange = selectRange;
            }
        }
    });
}

// MARK: UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    NSString *text = self.editTextView.text;
    NSInteger textLen = text.length;
    if (self.typingAttributes.count > 0 && textLen > 0) {
        NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithString:text];
        [mas addAttributes:self.typingAttributes range:NSMakeRange(0, textLen)];
        self.editTextView.attributedText = [mas copy];
    }
}

@end
