//
//  JTextField.m
//  BLE_Demo_OC
//
//  Created by 贾捷飞 on 2023/10/12.
//

#import "JTextField.h"

@implementation JTextField

//原文链接：https://blog.csdn.net/findhappy117/article/details/79478388
- (void) updateText:(NSString*)text {
    UITextRange* selectedTextRange = self.selectedTextRange;
    UITextPosition* beginning = self.beginningOfDocument;//文字开始的地方
    UITextPosition* startPosition = selectedTextRange.start;//光标开始的位置
    UITextPosition* endPosition = self.selectedTextRange.end;//光标结束的位置
    //获取光标开始位置在文字中所在的index
    NSInteger startIndex = [self offsetFromPosition:beginning toPosition:startPosition];
    //获取光标结束位置在文字中所在的index
    NSInteger endIndex = [self offsetFromPosition:beginning toPosition:endPosition];
    // 将输入框中的文字分成两部分，生成新字符串，判断新字符串是否满足要求
    NSString* originText = self.text;
    //从起始位置到当前index
    NSString* beforeString = [originText substringToIndex:startIndex];
    //从光标结束位置到末尾
    NSString* afterString = [originText substringFromIndex:endIndex];

    NSInteger offset;
    
    if (![text isEqualToString:@""]) {
        offset = text.length;
    } else {
        // 只删除一个字符
        if (startIndex == endIndex) {
            if (startIndex == 0) {
                return;
            }
            offset = -1;
            beforeString = [beforeString substringToIndex:beforeString.length - 1];
        } else {
            //光标选中多个
            offset = 0;
        }
    }
    NSString* newText = [NSString stringWithFormat:@"%@%@%@", beforeString, text, afterString];
    self.text = newText;
    
    // 重置光标位置
    UITextPosition* nowPosition = [self positionFromPosition:startPosition offset:offset];
    UITextRange* range = [self textRangeFromPosition:nowPosition toPosition:nowPosition];
    self.selectedTextRange = range;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
