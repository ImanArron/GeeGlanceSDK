//
//  BilibiliSceneController.m
//  Glance
//
//  Created by noctis on 2020/8/28.
//  Copyright © 2020 com.geetest. All rights reserved.
//

#import "BilibiliSceneController.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#import "ColorUtil.h"
#import "GlanceButton.h"
#import "GlanceSubmitConfirmWindow.h"
#import "WebViewController.h"
#import "BilibiliCommentCell.h"
#import <GeeGlanceSDK/GeeGlanceSDK.h>

@interface BilibiliSceneController () <GeeGlanceTextViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet GlanceButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;

@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) UIView *editView;
@property (nonatomic, strong) UIView *editBackgroundView;
@property (nonatomic, strong) GeeGlanceTextView *editTextView;
@property (nonatomic, strong) GlanceButton *sendButton;
@property (nonatomic, strong) UIImageView *hintImageView;

@property (nonatomic, strong) UIView *errorHintView;

@property (nonatomic, copy) NSDictionary *typingAttributes;
@property (nonatomic, assign) CGSize originEditTextViewSize;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSString *> *comments;

@end

@implementation BilibiliSceneController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.player pause];
    self.player = nil;
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
}

// MARK: View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"GTCaptcha_vertical" ofType:@"mp4"];
    if (path.length > 0) {
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:path]];
        if (nil != playerItem) {
            UIView *playerView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
            playerView.tag = 1003;
            playerView.backgroundColor = [UIColor whiteColor];
            playerView.alpha = 0.5;
            [self.view addSubview:playerView];
            [self.view sendSubviewToBack:playerView];
            self.playerView = playerView;
                        
            __weak typeof(self) wself = self;
            [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                CMTime time = CMTimeMake(0, 1);
                [wself.player seekToTime:time];
                [wself.player play];
            }];
            
            [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                [wself.player play];
            }];
            
            self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
            self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
            self.playerLayer.videoGravity = AVLayerVideoGravityResize;
            [self.playerView.layer addSublayer:self.playerLayer];
            self.playerLayer.frame = self.playerView.bounds;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSError *error = nil;
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
                if (nil != error) {
                    NSLog(@"AVAudioSession setCategory error: %@", error);
                }
                [self.player play];
            });
        }
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.cancelsTouchesInView = NO;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.player) {
        [self.player pause];
    }
}

// MARK: Actions

- (IBAction)backAction:(id)sender {
    self.transitioningDelegate = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)commentAction:(id)sender {
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

// MARK: TableView

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.estimatedRowHeight = 60.0;
        [_tableView registerNib:[UINib nibWithNibName:@"BilibiliCommentCell" bundle:nil] forCellReuseIdentifier:@"BilibiliCommentCell"];
    }
    return _tableView;
}

// MARK: UITableViewDataSource, UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BilibiliCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BilibiliCommentCell"];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *comment = self.comments[indexPath.row];
    NSString *user = [NSString stringWithFormat:@"#游客%ld：", 22345 + (long)indexPath.row];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
    [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:user attributes:@{NSFontAttributeName : [UIFont fontWithName:@"PingFang SC" size:13], NSForegroundColorAttributeName : [ColorUtil colorFromHexString:@"#4271DD"]}]];
    [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:comment attributes:@{NSFontAttributeName : [UIFont fontWithName:@"PingFang SC" size:13], NSForegroundColorAttributeName : [ColorUtil colorFromHexString:@"#FFFFFF"]}]];
    cell.commentContentLabel.attributedText = [attrStr copy];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

// MARK: Layout TableView

- (void)layoutTableView {
    if (!self.tableView.superview) {
        [self.view addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.commentButton.mas_top).offset(-10);
            make.leading.trailing.equalTo(self.view);
            make.height.mas_equalTo(60);
        }];
    }
    
    [self.tableView reloadData];
    
    CGFloat maxTableHeight = UIScreen.mainScreen.bounds.size.height - 116;
    if (@available(iOS 11.0, *)) {
        maxTableHeight -= (self.view.safeAreaInsets.top + self.view.safeAreaInsets.bottom);
    }
    if (self.comments.count > 20) {
        if (fabs(self.tableView.bounds.size.height - maxTableHeight) > 0.000001) {
            [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(maxTableHeight);
            }];
        }
    } else {
        CGFloat commentContentHeight = [self computeCommentContentHeight];
        if (commentContentHeight > maxTableHeight && fabs(self.tableView.bounds.size.height - maxTableHeight) > 0.000001) {
            [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(maxTableHeight);
            }];
        } else {
            [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(commentContentHeight);
            }];
        }
    }
    
    [self.view layoutIfNeeded];
    if (self.comments.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.comments.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (CGFloat)computeCommentContentHeight {
    CGFloat height = 0;
    for (NSInteger i = 0; i < self.comments.count; i++) {
        NSString *comment = self.comments[i];
        NSString *user = [NSString stringWithFormat:@"#游客%ld：", 22345 + (long)i];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
        [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:user attributes:@{NSFontAttributeName : [UIFont fontWithName:@"PingFang SC" size:13], NSForegroundColorAttributeName : [ColorUtil colorFromHexString:@"#4271DD"]}]];
        [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:comment attributes:@{NSFontAttributeName : [UIFont fontWithName:@"PingFang SC" size:13], NSForegroundColorAttributeName : [ColorUtil colorFromHexString:@"#FFFFFF"]}]];
        UILabel *label = [[UILabel alloc] init];
        label.attributedText = [attrStr copy];
        CGSize size = [label sizeThatFits:CGSizeMake(UIScreen.mainScreen.bounds.size.width - 32, CGFLOAT_MAX)];
        height += (size.height + 20);
    }
    
    return height;
}

// MARK: Edit View

static CGFloat const EditHeight = 40;
static CGFloat const EditTopMargin = 5;
static CGFloat const MAXEditHeight = 300;
static CGFloat const MAXInputCharactors = 100;

- (void)beginEditing {
    [self setupEditView];
    [self.editTextView becomeFirstResponder];
}

- (void)endEditing {
    [self.editTextView resignFirstResponder];
    [self hideErrorHintView];
}

- (void)setupEditView {
    if (0 == self.editView.subviews.count) {
        [self.editView addSubview:self.sendButton];
        [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.editView).offset(-10);
            make.centerY.equalTo(self.editView);
        }];
        
        [self.editView addSubview:self.editBackgroundView];
        [self.editBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.editView).offset(10);
            make.trailing.equalTo(self.sendButton.mas_leading).offset(-15);
            make.centerY.equalTo(self.editView);
            make.top.equalTo(self.editView).offset(EditTopMargin);
        }];
        
        [self.editBackgroundView addSubview:self.hintImageView];
        [self.hintImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.editBackgroundView).offset(-10);
            make.centerY.equalTo(self.editBackgroundView);
            make.width.height.mas_equalTo(12);
        }];
        
        [self.editBackgroundView addSubview:self.editTextView];
        [self.editTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.editBackgroundView).offset(10);
            make.centerY.equalTo(self.editBackgroundView);
            make.trailing.equalTo(self.hintImageView.mas_leading).offset(-5);
            make.height.mas_equalTo(EditHeight - 2*EditTopMargin);
        }];
        
        [self.view addSubview:self.editView];
        [self.editView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.view);
            make.height.mas_equalTo(EditHeight);
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(EditHeight + self.view.safeAreaInsets.bottom);
            } else {
                make.bottom.equalTo(self.view.mas_bottom).offset(EditHeight);
            }
        }];
        
        [self.view layoutIfNeeded];
        
        self.originEditTextViewSize = self.editTextView.bounds.size;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
}

- (UIView *)editView {
    if (!_editView) {
        _editView = [[UIView alloc] init];
        _editView.backgroundColor = [ColorUtil colorFromHexString:@"F4F4F4"];
    }
    return _editView;
}

- (UIView *)editBackgroundView {
    if (!_editBackgroundView) {
        _editBackgroundView = [[UIView alloc] init];
        _editBackgroundView.backgroundColor = UIColor.whiteColor;
        _editBackgroundView.layer.masksToBounds = YES;
        _editBackgroundView.layer.cornerRadius = (EditHeight - 2 * EditTopMargin)/2;
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
        _editTextView.maxLength = MAXInputCharactors;
        _editTextView.textContainerInset = UIEdgeInsetsMake(-2, 0, 0, 0);
        _editTextView.sceneKey = @"Bilibili";
        _editTextView.sceneType = GeeGlanceSceneTypeShort;
        // 自定义敏感字符标记颜色
        _editTextView.markBackgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.16];
        _editTextView.markUnderlineColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.64];
    }
    return _editTextView;
}

- (UIImageView *)hintImageView {
    if (!_hintImageView) {
        _hintImageView = [[UIImageView alloc] init];
        _hintImageView.hidden = YES;
    }
    return _hintImageView;
}

- (GlanceButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [GlanceButton buttonWithType:UIButtonTypeCustom];
        [_sendButton setBackgroundImage:[UIImage imageNamed:@"Vector"] forState:UIControlStateNormal];
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
        GlanceSubmitConfirmWindow *confirmWindow = [[GlanceSubmitConfirmWindow alloc] initWithBaseView:self.view attributedString:self.editTextView.attributedText confirmAction:^{
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

// MARK: Layout EditView

- (void)layoutEditView:(CGFloat)newHeight {
    if (newHeight > self.editTextView.bounds.size.height) {
        [self.editTextView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(newHeight);
        }];
        [self.editView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(MIN(EditHeight + newHeight - self.editTextView.bounds.size.height, MAXEditHeight));
        }];
        [self.view layoutIfNeeded];
    } else {
        [self.editTextView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(newHeight);
        }];
        [self.editView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(MIN(newHeight < self.originEditTextViewSize.height ? EditHeight : EditHeight + (newHeight - self.originEditTextViewSize.height), MAXEditHeight));
        }];
        [self.view layoutIfNeeded];
    }
}

// MARK: GeeGlanceTextViewDelegate

- (void)textView:(GeeGlanceTextView *)textView didGlanceStatusChanged:(GeeGlanceTextViewStatus)glanceStatus {
    [self setGlanceStatus:glanceStatus];
}

- (void)textView:(GeeGlanceTextView *)textView didTextHeightChanged:(CGFloat)textHeight {
    [self layoutEditView:textHeight];
}

// MARK: Glance Status

- (void)setGlanceStatus:(GeeGlanceTextViewStatus)status {
    switch (status) {
        case GeeGlanceTextViewStatusEmpty:
        {
            self.hintImageView.hidden = YES;
            [self hideErrorHintView];
        }
            break;
            
        case GeeGlanceTextViewStatusEditing:
        {
            self.hintImageView.hidden = NO;
            self.hintImageView.image = [UIImage imageNamed:@"Group 722"];
            [self hideErrorHintView];
        }
            break;
            
        case GeeGlanceTextViewStatusNormal:
        {
            self.hintImageView.hidden = NO;
            self.hintImageView.image = [UIImage imageNamed:@"Group 723"];
            [self hideErrorHintView];
        }
            break;
            
        case GeeGlanceTextViewStatusError:
        {
            self.hintImageView.hidden = NO;
            self.hintImageView.image = [UIImage imageNamed:@"Group 721"];
            [self showErrorHintView];
        }
            break;
            
        default:
            break;
    }
}

// MARK: Error HintView

- (void)showErrorHintView {
    if (0 == self.errorHintView.layer.sublayers.count) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, 10)];
        [path addLineToPoint:CGPointMake(0, 86)];
        [path addQuadCurveToPoint:CGPointMake(10, 96) controlPoint:CGPointMake(10.0 - 10.0*sin(M_PI/4), 86 + 10.0*sin(M_PI/4))];
        [path addLineToPoint:CGPointMake(44.5, 96)];
        [path addLineToPoint:CGPointMake(57.5, 109)];
        [path addLineToPoint:CGPointMake(70.5, 96)];
        [path addLineToPoint:CGPointMake(105, 96)];
        [path addQuadCurveToPoint:CGPointMake(115, 86) controlPoint:CGPointMake(105 + 10.0*sin(M_PI/4), 86 + 10.0*sin(M_PI/4))];
        [path addLineToPoint:CGPointMake(115, 10)];
        [path addQuadCurveToPoint:CGPointMake(105, 0) controlPoint:CGPointMake(105 + 10.0*sin(M_PI/4), 10.0 - 10.0*sin(M_PI/4))];
        [path addLineToPoint:CGPointMake(10, 0)];
        [path addQuadCurveToPoint:CGPointMake(0, 10) controlPoint:CGPointMake(10.0 - 10.0*sin(M_PI/4), 10.0 - 10.0*sin(M_PI/4))];

        CAShapeLayer *errorHintLayer = [CAShapeLayer layer];
        errorHintLayer.strokeColor = [ColorUtil colorFromHexString:@"#CEDCE5"].CGColor;
        errorHintLayer.fillColor = [ColorUtil colorFromHexString:@"#CEDCE5"].CGColor;
        errorHintLayer.lineWidth = 0.5;
        errorHintLayer.lineCap = kCALineCapRound;
        errorHintLayer.lineJoin = kCALineJoinRound;
        errorHintLayer.path = path.CGPath;
        [self.errorHintView.layer addSublayer:errorHintLayer];
    }
    
    if (!self.errorHintView.superview) {
        [self.editBackgroundView addSubview:self.errorHintView];
        [self.errorHintView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(115);
            make.height.mas_equalTo(109);
            make.centerX.equalTo(self.hintImageView);
            make.bottom.equalTo(self.hintImageView.mas_top);
        }];
        
//        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Rectangle"]];
//        [self.errorHintView addSubview:backgroundImageView];
//        [backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self.errorHintView);
//        }];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bilibili 1"]];
        [self.errorHintView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.errorHintView);
            make.bottom.equalTo(self.errorHintView).offset(-13);
        }];
        
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.85];
        label.font = [UIFont fontWithName:@"PingFang SC" size:11];
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 0;
        label.text = @"您输入的内容看起来不和谐呢，建议修改哦";
        [self.errorHintView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.equalTo(self.errorHintView).offset(10);
            make.trailing.equalTo(self.errorHintView).offset(-10);
        }];
    }
    
    if (self.errorHintView.hidden) {
        [UIView animateWithDuration:0.3 animations:^{
            self.errorHintView.hidden = NO;
        }];
    }
}

- (void)hideErrorHintView {
    if (!self.errorHintView.hidden) {
        [UIView animateWithDuration:0.3 animations:^{
            self.errorHintView.hidden = YES;
        }];
    }
}

- (UIView *)errorHintView {
    if (!_errorHintView) {
        _errorHintView = [[UIView alloc] init];
        _errorHintView.backgroundColor = [UIColor clearColor];
        _errorHintView.hidden = YES;
    }
    return _errorHintView;
}

// MARK: TextView Height

- (CGFloat)heightForTextView:(UITextView *)textView withText:(NSString *)text {
    CGSize constraint = CGSizeMake(textView.contentSize.width , CGFLOAT_MAX);
    CGRect size = [text boundingRectWithSize:constraint
                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                  attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}
                                     context:nil];
    float textHeight = size.size.height + 22.0;
    return textHeight;
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
                    make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(2*EditHeight + self.view.safeAreaInsets.bottom);
                } else {
                    make.bottom.equalTo(self.view.mas_bottom).offset(EditHeight);
                }
            }];
            
            [self.view layoutIfNeeded];
        }];
    }
}

@end
