//
//  BaseViewController.m
//  Glance
//
//  Created by noctis on 2020/9/4.
//  Copyright © 2020 com.geetest. All rights reserved.
//

#import "BaseViewController.h"

@interface GlanceInteractiveTransition : UIPercentDrivenInteractiveTransition

- (instancetype)initWithGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer;

@end

@interface GlanceInteractiveTransition () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIPanGestureRecognizer *panGesture;
@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, assign) CGPoint startLocation;

@end

@implementation GlanceInteractiveTransition

// MARK: Dealloc

- (void)dealloc {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.panGesture removeTarget:self action:@selector(panAction:)];
}

// MARK: Init

- (instancetype)initWithGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)panGestureRecognizer {
    self = [super init];
    if (self) {
        self.panGesture = panGestureRecognizer;
        self.panGesture.delegate = self;
        [self.panGesture addTarget:self action:@selector(panAction:)];
    }
    return self;
}

// MARK: startInteractiveTransition

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    [super startInteractiveTransition:transitionContext];
    // 保存交互上下文，方便做进度更新等操作
    self.transitionContext = transitionContext;
}

// MARK: Pan Action

- (void)panAction:(UIPanGestureRecognizer *)panGesture {
    NSLog(@"Glance interactive transition pan action.");
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            UIView *transitionContainerView = self.transitionContext.containerView;
            CGPoint locationInView = [panGesture locationInView:transitionContainerView];
            self.startLocation = locationInView;
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            UIView *transitionContainerView = self.transitionContext.containerView;
            CGPoint locationInView = [panGesture locationInView:transitionContainerView];
            if (locationInView.y < self.startLocation.y ||
                locationInView.x < self.startLocation.x) {
                [self cancelInteractiveTransition];
                return;
            }
            
            [self updateInteractiveTransition:[self percentForGesture:self.panGesture]];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            if ([self percentForGesture:self.panGesture] >= 0.2) {
                [self finishInteractiveTransition];
            } else {
                [self cancelInteractiveTransition];
            }
        }
            break;
            
        default:
            [self cancelInteractiveTransition];
            break;
    }
}

- (CGFloat)percentForGesture:(UIPanGestureRecognizer *)gesture {
    UIView *transitionContainerView = self.transitionContext.containerView;
    CGPoint locationInView = [gesture locationInView:transitionContainerView];
    if (fabs(locationInView.x - self.startLocation.x) < 20) {
        return 0;
    }
    
    CGFloat width = CGRectGetWidth(transitionContainerView.bounds);
    return 1.0 - (width - locationInView.x) / width;
}

// MARK: UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.transitionContext.containerView];
        CGFloat absX = fabs(translation.x);
        CGFloat absY = fabs(translation.y);
        if (absY > absX) {
            
        }
    }
    return YES;
}

@end

@interface BaseViewController () <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning>

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) GlanceInteractiveTransition *transition;

@end

@implementation BaseViewController

// MARK: Dealloc

- (void)dealloc {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

// MARK: View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.transitioningDelegate = self;
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self.view addGestureRecognizer:self.panGesture];
    
    self.transition = [[GlanceInteractiveTransition alloc] initWithGestureRecognizer:self.panGesture];
}

// MARK: Action

- (void)panAction:(UIScreenEdgePanGestureRecognizer *)panGesture {
    if (UIGestureRecognizerStateBegan == panGesture.state && [self.transitioningDelegate isKindOfClass:[BaseViewController class]]) {
        NSLog(@"Bilibili scene controller pan action.");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// MARK: UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return self.transition;
}

// MARK: UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = fromVc.view;
    fromView.frame = [transitionContext initialFrameForViewController:fromVc];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^{
        fromView.frame = CGRectMake(0, fromView.bounds.size.height, fromView.bounds.size.width, fromView.bounds.size.height);
    } completion:^(BOOL finished) {
        BOOL cancelTransition = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!cancelTransition];
    }];
}

// MARK: UIViewControllerInteractiveTransitioning

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
}

@end
