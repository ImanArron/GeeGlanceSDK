//
//  GeeGlanceTextView.h
//  GeeGlance
//
//  Created by noctis on 2020/9/24.
//  Copyright © 2020 com.geetest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeeGlanceManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GeeGlanceTextViewStatus) {
    GeeGlanceTextViewStatusEmpty,
    GeeGlanceTextViewStatusEditing,
    GeeGlanceTextViewStatusNormal,
    GeeGlanceTextViewStatusError
};

@protocol GeeGlanceTextViewDelegate;

@interface GeeGlanceTextView : UIView

@property (nonatomic, copy) NSString *sceneKey;
@property (nonatomic, assign) GeeGlanceSceneType sceneType;

@property (null_resettable, nonatomic, copy) NSString *text;
@property (nullable, nonatomic, strong) UIFont *font;
@property (nullable, nonatomic, strong) UIColor *textColor;
@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, copy) NSString *placeholder;
@property (nullable, nonatomic, strong) UIFont *placeholderFont;
@property (nullable, nonatomic, strong) UIColor *placeholderColor;

@property (nonatomic, readonly) BOOL canBecomeFirstResponder;    // default is NO
- (BOOL)becomeFirstResponder;

@property (nonatomic, readonly) BOOL canResignFirstResponder;    // default is YES
- (BOOL)resignFirstResponder;

@property (nonatomic, readonly) BOOL isFirstResponder;

@property (nonatomic, copy, nullable) NSAttributedString *attributedText;

@property (nonatomic, assign) UIEdgeInsets textContainerInset;

@property (nonatomic, assign) NSInteger maxLength;

@property (nonatomic, weak) id<GeeGlanceTextViewDelegate> delegate;

@property (nonatomic, strong, readonly) NSMutableArray<GeeGlanceMatchResult *> *matchResults;

// 敏感字符标记背景色
@property (nonatomic, strong, nonnull) UIColor *markBackgroundColor;
// 敏感字符标记下划线色
@property (nonatomic, strong, nonnull) UIColor *markUnderlineColor;

/**
 @abstract 设置 textview 的 placeholder
 
 @param text placeholder 文案
 */
- (void)handlePlaceholderWithReplacementText:(NSString * _Nullable)text;

/**
 @abstract 提交 textview 中的输入内容
 
 @param completionHandler 回调
 
 @discussion 回调中包含两个字段
             text - textview 中的输入内容
             results - 匹配结果
 */
- (void)submitWithCompletionHandler:(void(^)(NSString *text, NSMutableArray<GeeGlanceMatchResult *> *results))completionHandler;

/**
 @abstract 重置 textview 中的输入内容及匹配结果
 */
- (void)resetTextAndMatchResult;

@end

@protocol GeeGlanceTextViewDelegate <NSObject>

@optional
- (void)textView:(GeeGlanceTextView *)textView didGlanceStatusChanged:(GeeGlanceTextViewStatus)glanceStatus;
- (void)textView:(GeeGlanceTextView *)textView didTextHeightChanged:(CGFloat)textHeight;

- (BOOL)textViewShouldBeginEditing:(GeeGlanceTextView *)textView;
- (BOOL)textViewShouldEndEditing:(GeeGlanceTextView *)textView;

- (void)textViewDidBeginEditing:(GeeGlanceTextView *)textView;
- (void)textViewDidEndEditing:(GeeGlanceTextView *)textView;

- (BOOL)textView:(GeeGlanceTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)textViewDidChange:(GeeGlanceTextView *)textView;

- (void)textViewDidChangeSelection:(GeeGlanceTextView *)textView;

- (BOOL)textView:(GeeGlanceTextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction API_AVAILABLE(ios(10.0));
- (BOOL)textView:(GeeGlanceTextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction API_AVAILABLE(ios(10.0));

@end

NS_ASSUME_NONNULL_END
