//
//  LockView.m
//  手势解锁
//
//  Created by 许树铎 on 16/3/1.
//  Copyright © 2016年 许树铎. All rights reserved.
//

#import "LockView.h"

#define errCount 5  // 允许错误的次数
#define errWaitTime 5   // 当密码错误次数上限等待的时间
@interface LockView ()

@property (nonatomic, strong) NSMutableArray *selectBtnArray;   // 选择的Btn数组
@property (nonatomic, assign) CGPoint curP; // 获取上一个点
@property (nonatomic, strong) NSString *psw;    // 保存图案密码
@property (nonatomic, assign) NSInteger pswErr;    // 密码错误次数

@end

@implementation LockView

- (NSMutableArray *)selectBtnArray {
    if (!_selectBtnArray) {
        _selectBtnArray = [NSMutableArray array];
    }
    return _selectBtnArray;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib {
    [self setUp];
}

- (void)drawRect:(CGRect)rect {
    if (self.selectBtnArray.count) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        for (int i = 0; i < self.selectBtnArray.count; i++) {
            UIButton *btn = self.selectBtnArray[i];
            if (i == 0) {
                // 起点
                [path moveToPoint:btn.center];
            } else {
                // 连接
                [path addLineToPoint:btn.center];
            }
        }
        [path addLineToPoint:self.curP];
        
        // 设置线
        [path setLineWidth:20];
        [path setLineCapStyle:kCGLineCapRound];
        [path setLineJoinStyle:kCGLineJoinRound];
        [[UIColor colorWithRed:0.792 green:0.969 blue:1.000 alpha:1] set];
        [path stroke];
    }
}

- (void)setUp {
    CGFloat viewWH = self.bounds.size.height;
    CGFloat BtnWH = 74;
    CGFloat margin = (viewWH - 3 * BtnWH) / 4;
    for (int i = 0; i < 9 ; i++) {
        UIButton *btn = [UIButton buttonWithType:0];
        [btn setImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"gesture_node_selected"] forState:UIControlStateSelected];
        btn.frame = CGRectMake(margin + margin * (i % 3) + BtnWH * (i % 3), margin + margin * (i / 3) + BtnWH * (i / 3), BtnWH, BtnWH);
        btn.tag = i;
        btn.userInteractionEnabled = NO;
        [self addSubview:btn];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 判断是点击按钮还是View
    // 获取当前点击的坐标
    CGPoint curP = [self getCurPoint:touches];
    UIButton *btn = [self btnContainsPoint:curP];
    if (btn && btn.selected == NO) {
        btn.selected = YES;
        [self.selectBtnArray addObject:btn];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint curP = [self getCurPoint:touches];
    UIButton *btn = [self btnContainsPoint:curP];
    if (btn && btn.selected == NO) {
        btn.selected = YES;
        [self.selectBtnArray addObject:btn];
    }
    self.curP = curP;
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSMutableString *result = [NSMutableString string];
    for (UIButton *btn in self.selectBtnArray) {
        btn.selected = NO;
        [result appendFormat:@"%zd", btn.tag];
    }
    if (!_psw) {
        // 第一次保存手势密码
        if (result.length < 4) {
            NSLog(@"请至少连接4个点");
            [self setTip:@"请至少连接4个点！"];
        } else {
            self.psw = result;
            NSLog(@"解锁图已录入！");
            [self setTip:@"解锁图已录入，请输入图案密码解锁！"];
        }
    } else if([self.psw isEqualToString:result]) {
        NSLog(@"解锁图案正确！");
        [self setTip:@"解锁图案正确！"];
        _pswErr = 0;
    } else {
        if (_pswErr >= errCount - 1) {
            [self setTip:[NSString stringWithFormat:@"图案密码错误次数上限，请%zd分钟后重试！", errWaitTime]];
            self.userInteractionEnabled = NO;
            [NSTimer scheduledTimerWithTimeInterval:errWaitTime * 60 target:self selector:@selector(unErrLock) userInfo:nil repeats:NO];
        } else {
            _pswErr ++;
            NSLog(@"解锁图案错误！");
            [self setTip:[NSString stringWithFormat:@"解锁图案错误，你还有%ld次机会！", errCount - _pswErr]];
        }
    }
    [self.selectBtnArray removeAllObjects];
    [self setNeedsDisplay];
}

- (void)setTip:(NSString *)str {
    [UIView animateWithDuration:0.25 animations:^{
        self.tipLabel.transform = CGAffineTransformMakeScale(1.5, 1.5);
        self.tipLabel.alpha = 0.5;
    } completion:^(BOOL finished) {
        self.tipLabel.text = str;
        [UIView animateWithDuration:0.25 animations:^{
            self.tipLabel.transform = CGAffineTransformMakeScale(1, 1);
            self.tipLabel.alpha = 1;
        }];
    }];
}

- (void)unErrLock {
    self.userInteractionEnabled = YES;
    _pswErr = 0;
    self.tipLabel.text = @"请输入图案密码解锁！";
}

- (CGPoint)getCurPoint:(NSSet *)touches {
    UITouch *touch = [touches anyObject];
    return [touch locationInView:self];
}

- (UIButton *)btnContainsPoint:(CGPoint)point {
    for (UIButton *btn in self.subviews) {
        if (CGRectContainsPoint(btn.frame, point)) {
            return btn;
        }
    }
    return nil;
}

@end
