//
//  CommentSceneController.m
//  Glance
//
//  Created by noctis on 2020/9/2.
//  Copyright © 2020 com.geetest. All rights reserved.
//

#import "CommentSceneController.h"
#import "DistributeCommentCell.h"
#import "GlanceButton.h"
#import "Masonry.h"
#import "ColorUtil.h"
#import "GlanceSubmitConfirmWindow.h"
#import "WebViewController.h"
#import <GeeGlanceSDK/GeeGlanceSDK.h>

@interface CommentSceneController () <UITableViewDataSource, UITableViewDelegate, GeeGlanceTextViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *navigationView;
@property (weak, nonatomic) IBOutlet GlanceButton *backButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSString *> *comments;

@property (nonatomic, strong) UIView *editView;
@property (nonatomic, strong) UIView *editBackgroundView;
@property (nonatomic, strong) GeeGlanceTextView *editTextView;
@property (nonatomic, strong) GlanceButton *sendButton;
@property (nonatomic, strong) UILabel *hintLabel;

@end

@implementation CommentSceneController

// MARK: View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupViews];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.cancelsTouchesInView = NO;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)setupViews {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.estimatedRowHeight = 60.0;
    [self.tableView registerNib:[UINib nibWithNibName:@"DistributeCommentCell" bundle:nil] forCellReuseIdentifier:@"DistributeCommentCell"];
}

// MARK: Actions

- (IBAction)backAction:(id)sender {
    self.transitioningDelegate = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendCommentAction:(id)sender {
    [self beginEditing];
}

- (void)tapAction:(UITapGestureRecognizer *)tapGesture {
    [self endEditing];
}

// MARK: UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.editView]) {
        return NO;
    }
    
    return YES;
}

// MARK: Comments

- (NSMutableArray<NSString *> *)comments {
    if (!_comments) {
        _comments = [NSMutableArray array];
    }
    return _comments;
}

// MARK: Layout TableView

- (void)layoutTableView {
    self.tableView.hidden = (0 == self.comments.count);
    [self.tableView reloadData];
}

// MARK: UITableViewDataSource, UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DistributeCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DistributeCommentCell"];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userNameLabel.text = [NSString stringWithFormat:@"游客%ld", (long)(8848 + indexPath.row)];
    cell.userCommentLabel.text = self.comments[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

// MARK: Edit View

static CGFloat const CommentEditHeight = 126;
static CGFloat const CommentMAXInputCharactors = 200;

- (void)beginEditing {
    [self setupEditView];
    [self.editTextView becomeFirstResponder];
}

- (void)endEditing {
    [self.editTextView resignFirstResponder];
}

- (void)setupEditView {
    if (0 == self.editView.subviews.count) {
        [self.editView addSubview:self.sendButton];
        [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.editView).offset(-10);
            make.bottom.equalTo(self.editView).offset(-10);
            make.width.height.mas_equalTo(20);
        }];
        
        [self.editView addSubview:self.editBackgroundView];
        [self.editBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.editView).offset(10);
            make.trailing.equalTo(self.sendButton.mas_leading).offset(-15);
            make.bottom.equalTo(self.editView).offset(-5);
            make.top.equalTo(self.editView).offset(10);
        }];
        
        [self.editBackgroundView addSubview:self.hintLabel];
        [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.editBackgroundView).offset(-10);
            make.bottom.equalTo(self.editBackgroundView).offset(-10);
        }];
        
        [self.editBackgroundView addSubview:self.editTextView];
        [self.editTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.editBackgroundView).offset(10);
            make.top.equalTo(self.editBackgroundView).offset(10);
            make.trailing.equalTo(self.editBackgroundView).offset(-10);
            make.bottom.equalTo(self.editBackgroundView).offset(-10);
        }];
        
        [self.view addSubview:self.editView];
        [self.editView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.height.mas_equalTo(CommentEditHeight);
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(CommentEditHeight + self.view.safeAreaInsets.bottom);
            } else {
                make.bottom.equalTo(self.view.mas_bottom).offset(CommentEditHeight);
            }
        }];
        
        [self.view layoutIfNeeded];
                
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
}

- (UIView *)editView {
    if (!_editView) {
        _editView = [[UIView alloc] init];
        _editView.backgroundColor = [ColorUtil colorFromHexString:@"FFFFFF"];
    }
    return _editView;
}

- (UIView *)editBackgroundView {
    if (!_editBackgroundView) {
        _editBackgroundView = [[UIView alloc] init];
        _editBackgroundView.backgroundColor = [ColorUtil colorFromHexString:@"F4F4F4"];
        _editBackgroundView.layer.masksToBounds = YES;
        _editBackgroundView.layer.cornerRadius = 12;
        _editBackgroundView.layer.borderColor = [ColorUtil colorFromHexString:@"#E7E7E7"].CGColor;
        _editBackgroundView.layer.borderWidth = 0.5;
        _editBackgroundView.clipsToBounds = NO;
    }
    return _editBackgroundView;
}

- (GeeGlanceTextView *)editTextView {
    if (!_editTextView) {
        _editTextView = [[GeeGlanceTextView alloc] init];
        _editTextView.backgroundColor = [UIColor clearColor];
        _editTextView.delegate = self;
        _editTextView.maxLength = CommentMAXInputCharactors;
        _editTextView.placeholder = @"在这里违规的内容将会被直接识别并展示，请输入您的评论。";
        _editTextView.sceneKey = @"Comment";
        _editTextView.sceneType = GeeGlanceSceneTypeMedium;
    }
    return _editTextView;
}

- (UILabel *)hintLabel {
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.backgroundColor = [UIColor clearColor];
    }
    return _hintLabel;
}

- (GlanceButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [GlanceButton buttonWithType:UIButtonTypeCustom];
        [_sendButton setBackgroundImage:[UIImage imageNamed:@"Vector-Disabled"] forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

// MARK: Send Action

- (void)sendAction:(UIButton *)button {
    [self endEditing];
    __weak typeof(self) wself = self;
    [GTProgressHUD showLoadingHUDWithMessage:@"智能匹配中…"];
    [self.editTextView submitWithCompletionHandler:^(NSString * _Nonnull text, NSMutableArray<GeeGlanceMatchResult *> * _Nonnull results) {
        [GTProgressHUD hideAllHUD];
        [wself confirmSendContent:text matchResults:results];
    }];
}

- (void)confirmSendContent:(NSString *)content matchResults:(NSMutableArray<GeeGlanceMatchResult *> *)matchResults {
    if (matchResults.count > 0) {
        __weak typeof(self) wself = self;
        GlanceSubmitConfirmWindow *confirmWindow = [[GlanceSubmitConfirmWindow alloc] initWithBaseView:self.view attributedString:nil confirmAction:^{
            if (wself.editTextView.text.length > 0) {
                [wself.comments addObject:wself.editTextView.text];
                [wself layoutTableView];
            }
            
            [wself.editTextView resetTextAndMatchResult];
        } cancelAction:^{
            [wself beginEditing];
        } handleProtocolBlock:^(NSURL * _Nonnull URL) {
            if (URL) {
                WebViewController *controller = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:[NSBundle mainBundle]];
                controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
                controller.URL = URL;
                [wself presentViewController:controller animated:YES completion:nil];
            }
        }];
        [confirmWindow showWindow];
    } else {
        if (content.length > 0) {
            [self.comments addObject:self.editTextView.text];
            [self layoutTableView];
        }
        [self.editTextView resetTextAndMatchResult];
    }
}

// MARK: GeeGlanceTextViewDelegate

- (void)textView:(GeeGlanceTextView *)textView didGlanceStatusChanged:(GeeGlanceTextViewStatus)glanceStatus {
    [self setGlanceStatus:glanceStatus];
}

// MARK: Hint Status

- (void)setGlanceStatus:(GeeGlanceTextViewStatus)status {
    switch (status) {
        case GeeGlanceTextViewStatusEmpty:
        {
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            attachment.image = [UIImage imageNamed:@"Group 752"];
            attachment.bounds = CGRectMake(0, -2.5, 12, 12);
            self.hintLabel.attributedText = [NSAttributedString attributedStringWithAttachment:attachment];
            [self.sendButton setBackgroundImage:[UIImage imageNamed:@"Vector-Disabled"] forState:UIControlStateNormal];
            [self.editTextView handlePlaceholderWithReplacementText:nil];
        }
            break;
            
        case GeeGlanceTextViewStatusEditing:
        {
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            attachment.image = [UIImage imageNamed:@"Group 722"];
            attachment.bounds = CGRectMake(0, -2.5, 12, 12);
            self.hintLabel.attributedText = [NSAttributedString attributedStringWithAttachment:attachment];
            [self.sendButton setBackgroundImage:[UIImage imageNamed:@"Vector"] forState:UIControlStateNormal];
        }
            break;
            
        case GeeGlanceTextViewStatusNormal:
        {
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            attachment.image = [UIImage imageNamed:@"Group 723"];
            attachment.bounds = CGRectMake(0, -2.5, 12, 12);
            self.hintLabel.attributedText = [NSAttributedString attributedStringWithAttachment:attachment];
            [self.sendButton setBackgroundImage:[UIImage imageNamed:@"Vector"] forState:UIControlStateNormal];
        }
            break;
            
        case GeeGlanceTextViewStatusError:
        {
            NSMutableAttributedString *mutableAttrStr = [[NSMutableAttributedString alloc] init];
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            attachment.image = [UIImage imageNamed:@"Group 721"];
            attachment.bounds = CGRectMake(0, -2.5, 12, 12);
            [mutableAttrStr appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
            
            NSAttributedString *hintAttrStr = [[NSAttributedString alloc] initWithString:@"  监测到有不和谐内容，建议修改" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:11], NSForegroundColorAttributeName : [ColorUtil colorFromHexString:@"#929292"]}];
            [mutableAttrStr appendAttributedString:hintAttrStr];
            self.hintLabel.attributedText = [mutableAttrStr copy];
            [self.sendButton setBackgroundImage:[UIImage imageNamed:@"Vector"] forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
}

// MARK: Keyboard

- (void)keyboardWillShow:(NSNotification *)noti {
    if (nil != [noti userInfo]) {
        CGRect keyboardFrame = [[noti userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat duration = [[noti userInfo][UIKeyboardAnimationDurationUserInfoKey] floatValue];
        [UIView animateWithDuration:duration animations:^{
            [self.editView mas_updateConstraints:^(MASConstraintMaker *make) {
                if (@available(iOS 11.0, *)) {
                    make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-keyboardFrame.size.height + self.view.safeAreaInsets.bottom);
                } else {
                    make.bottom.equalTo(self.view.mas_bottom).offset(-keyboardFrame.size.height);
                }
            }];
            
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)noti {
    if (nil != [noti userInfo]) {
        CGFloat duration = [[noti userInfo][UIKeyboardAnimationDurationUserInfoKey] floatValue];
        [UIView animateWithDuration:duration animations:^{
            [self.editView mas_updateConstraints:^(MASConstraintMaker *make) {
                if (@available(iOS 11.0, *)) {
                    make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(2*CommentEditHeight + self.view.safeAreaInsets.bottom);
                } else {
                    make.bottom.equalTo(self.view.mas_bottom).offset(CommentEditHeight);
                }
            }];
            
            [self.view layoutIfNeeded];
        }];
    }
}

@end
