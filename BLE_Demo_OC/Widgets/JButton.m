//
//  JButton.m
//  BLE_Demo_OC
//
//  Created by 贾捷飞 on 2023/10/12.
//

#import "JButton.h"

@implementation JButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;//允许绘制
//        self.layer.cornerRadius = 4;//边框弧度
        self.layer.borderColor = UIColor.grayColor.CGColor;//边框颜色
        self.layer.borderWidth = 0.3;//边框的宽度
    }
    return self;
}

- (void) startTimer {
    if (timer == nil) {
//        NSLog(@"startTimer");
        //TimeInterval是 Double 类型，单位是秒
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//            NSLog(@"Timer running... %ld", self->count);
            self->count += 1;
            if (self -> count >= 5) {//0.5秒触发持续长按                
//                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                    //主线程执行
//                }];
                if([self.delegate respondsToSelector:@selector(continuousPressedEvent:)]){
                    [self.delegate continuousPressedEvent:self];
                }
            }
        }];
    }
}

- (void) stopTimer {
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self setBackgroundColor:UIColor.grayColor];
    count = 0;
    if (self.withContinuousPressedEvent) {
        [self startTimer];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self setBackgroundColor:UIColor.whiteColor];
    [self stopTimer];
    if (!self.withContinuousPressedEvent || count < 5) {//0.5秒以内相当于点击
        if ([self.delegate respondsToSelector:@selector(clickEvent:)]) {
            [self.delegate clickEvent:self];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
