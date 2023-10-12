//
//  CharacteristicCell.h
//  BLE_Demo_OC
//
//  Created by 贾捷飞 on 2023/10/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CharacteristicCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelUUID;
@property (weak, nonatomic) IBOutlet UILabel *labelProperties;
@property (weak, nonatomic) IBOutlet UIButton *buttonRead;
@property (weak, nonatomic) IBOutlet UIButton *buttonWrite;
@property (weak, nonatomic) IBOutlet UISwitch *switchNotify;

@end

NS_ASSUME_NONNULL_END
