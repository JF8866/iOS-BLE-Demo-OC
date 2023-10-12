//
//  HexInputViewController.m
//  BLE_Demo_OC
//
//  Created by 贾捷飞 on 2023/10/12.
//

#import "HexInputViewController.h"

@interface HexInputViewController ()
@property (weak, nonatomic) IBOutlet JTextField *hexTextField;

@end


static NSString * const KEY_TITLES[18] = {
    @"A", @"B", @"C",
    @"D", @"E", @"F",
    @"1", @"2", @"3",
    @"4", @"5", @"6",
    @"7", @"8", @"9",
    @"DEL", @"0", @"DONE"
};

@implementation HexInputViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //输入框使用自定义的键盘
    self.hexTextField.inputView = self.inputView;
    //自动弹出键盘
    [self.hexTextField becomeFirstResponder];
    
}

- (__kindof UIView *)inputView{
    //自定义键盘View
    //获取屏幕宽度，用于计算每列按键的宽度
    CGFloat screenWidth = UIApplication.sharedApplication.statusBarFrame.size.width;
    //按键的宽高
    CGFloat keyViewWidth = screenWidth / 3;
    CGFloat keyViewHeight = 54;
    
    //创建6行3列的按键
    int rows = 6;
    int cols = 3;
    int count = rows * cols;
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, keyViewHeight * rows)];
    for (int i = 0; i < count; i++) {
        JButton* button = [[JButton alloc] initWithFrame:CGRectMake((i % cols)*keyViewWidth, (i/cols)*keyViewHeight, keyViewWidth, keyViewHeight)];
        UIColor* titleColor;
        switch (i) {
        case 15://删除键显示红色
                titleColor = UIColor.systemRedColor;
                break;
        case 17://完成键显示蓝色
                titleColor = UIColor.systemBlueColor;
                break;
        default:
                titleColor = UIColor.blackColor;
                break;
        }
        [button setTitle:KEY_TITLES[i] forState:UIControlStateNormal];
        [button setTitleColor:titleColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        button.backgroundColor = UIColor.whiteColor;
        button.withContinuousPressedEvent = (i != 17); //DONE 键只有点击事件
        button.delegate = self; //设置点击事件的委托
        [view addSubview:button];
    }
    return view;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) handleButtonClick:(UIButton*) button {
    NSString* title = button.currentTitle;
    //print("\(DataUtil.currentTime()) - \(#function) input: \(title)")
    if ([KEY_TITLES[15] isEqualToString:title]) {//“删除”键
        [self.hexTextField updateText:@""];
    } else if ([KEY_TITLES[17] isEqualToString:title]) {//“完成”键
        if ([self.delegate respondsToSelector:@selector(hexInputDone:)]) {
            [self.delegate hexInputDone:self.hexTextField.text];
        }
        //返回上一界面
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.hexTextField updateText:title];
    }
}

//按键点击事件
- (void)clickEvent:(nonnull JButton *)sender {
    [self handleButtonClick:sender];
}

//按键按住不放，持续触发的事件
- (void)continuousPressedEvent:(nonnull JButton *)sender {
    [self handleButtonClick:sender];
}


@end
