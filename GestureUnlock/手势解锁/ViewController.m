//
//  ViewController.m
//  手势解锁
//
//  Created by 许树铎 on 16/3/1.
//  Copyright © 2016年 许树铎. All rights reserved.
//

#import "ViewController.h"
#import "LockView.h"

@interface ViewController ()

@property (nonatomic, strong) IBOutlet LockView *lockView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lockView.tipLabel = self.tipLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
