//
//  JButton.h
//  BLE_Demo_OC
//
//  Created by 贾捷飞 on 2023/10/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JButtonDelegate;

///自定义Button，实现按住持续触发长按事件
@interface JButton : UIButton{
    NSTimer* timer;
    NSInteger count;
}

@property(nullable, weak, nonatomic) id<JButtonDelegate> delegate;
@property(nonatomic, assign) BOOL withContinuousPressedEvent;

@end


@protocol JButtonDelegate <NSObject>

- (void)continuousPressedEvent:(JButton*)sender;
- (void)clickEvent:(JButton*)sender;

@end

NS_ASSUME_NONNULL_END
