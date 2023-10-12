//
//  DeviceCell.h
//  BLE_Demo_OC
//
//  Created by 贾捷飞 on 2023/10/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelLocalName;
@property (weak, nonatomic) IBOutlet UILabel *labelDeviceID;
@property (weak, nonatomic) IBOutlet UILabel *labelManufacturerData;
@property (weak, nonatomic) IBOutlet UILabel *labelRSSI;

@end

NS_ASSUME_NONNULL_END
