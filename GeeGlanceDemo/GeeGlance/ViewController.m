//
//  ViewController.m
//  Glance
//
//  Created by noctis on 2020/8/27.
//  Copyright © 2020 com.geetest. All rights reserved.
//

#import "ViewController.h"
#import "ColorUtil.h"
#import "BilibiliSceneController.h"
#import "DistributeSceneController.h"
#import "CommentSceneController.h"
#import "CustomSceneController.h"

static NSInteger const SelectedTag = 1000;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *commentSceneButton;
@property (weak, nonatomic) IBOutlet UIButton *bilibiliSceneButton;
@property (weak, nonatomic) IBOutlet UIButton *distributeSceneButton;
@property (weak, nonatomic) IBOutlet UIButton *customSceneButton;
@property (copy, nonatomic) NSArray *sceneButtons;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.commentSceneButton.tag = SelectedTag;
    self.sceneButtons = @[self.commentSceneButton, self.bilibiliSceneButton, self.distributeSceneButton, self.customSceneButton];
}

// MARK: Actions

- (IBAction)commentAction:(id)sender {
    self.commentSceneButton.tag = SelectedTag;
    self.bilibiliSceneButton.tag = 0;
    self.distributeSceneButton.tag = 0;
    self.customSceneButton.tag = 0;
    [self sceneAction];
}

- (IBAction)bilibiliAction:(id)sender {
    self.commentSceneButton.tag = 0;
    self.bilibiliSceneButton.tag = SelectedTag;
    self.distributeSceneButton.tag = 0;
    self.customSceneButton.tag = 0;
    [self sceneAction];
}

- (IBAction)distributeAction:(id)sender {
    self.commentSceneButton.tag = 0;
    self.bilibiliSceneButton.tag = 0;
    self.distributeSceneButton.tag = SelectedTag;
    self.customSceneButton.tag = 0;
    [self sceneAction];
}

- (IBAction)customAction:(id)sender {
    self.commentSceneButton.tag = 0;
    self.bilibiliSceneButton.tag = 0;
    self.distributeSceneButton.tag = 0;
    self.customSceneButton.tag = SelectedTag;
    [self sceneAction];
}

- (void)sceneAction {
    for (UIButton *button in self.sceneButtons) {
        if (SelectedTag == button.tag) {
            button.backgroundColor = [ColorUtil colorFromHexString:@"#7E84AA"];
            [button setTitleColor:[ColorUtil colorFromHexString:@"#FFFFFF"] forState:UIControlStateNormal];
        } else {
            button.backgroundColor = [ColorUtil colorFromHexString:@"#E7ECF5"];
            [button setTitleColor:[ColorUtil colorFromHexString:@"#3B426B"] forState:UIControlStateNormal];
        }
    }
}

- (IBAction)testAction:(id)sender {
    if (SelectedTag == self.commentSceneButton.tag) {
        CommentSceneController *controller = [[CommentSceneController alloc] initWithNibName:@"CommentSceneController" bundle:[NSBundle mainBundle]];
        controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:controller animated:YES completion:nil];
    } else if (SelectedTag == self.bilibiliSceneButton.tag) {
        BilibiliSceneController *controller = [[BilibiliSceneController alloc] initWithNibName:@"BilibiliSceneController" bundle:[NSBundle mainBundle]];
        controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:controller animated:YES completion:nil];
    } else if (SelectedTag == self.distributeSceneButton.tag) {
        DistributeSceneController *controller = [[DistributeSceneController alloc] initWithNibName:@"DistributeSceneController" bundle:[NSBundle mainBundle]];
        controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:controller animated:YES completion:nil];
    } else if (SelectedTag == self.customSceneButton.tag) {
        CustomSceneController *controller = [[CustomSceneController alloc] initWithNibName:@"CustomSceneController" bundle:[NSBundle mainBundle]];
        controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

@end
