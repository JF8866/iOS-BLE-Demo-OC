//
//  HexInputViewController.h
//  BLE_Demo_OC
//
//  Created by 贾捷飞 on 2023/10/12.
//

#import <UIKit/UIKit.h>
#import "JButton.h"
#import "JTextField.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HexInputViewControllerDelegate;

@interface HexInputViewController : UIViewController<JButtonDelegate>

@property(nullable, weak, nonatomic) id<HexInputViewControllerDelegate> delegate;

@end

@protocol HexInputViewControllerDelegate <NSObject>

- (void)hexInputDone:(NSString*)hexString;

@end

NS_ASSUME_NONNULL_END
