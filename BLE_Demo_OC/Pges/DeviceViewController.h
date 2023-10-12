//
//  DeviceViewController.h
//  BLE_Demo_OC
//
//  Created by 贾捷飞 on 2023/10/8.
//

#import <UIKit/UIKit.h>
#import "BleManager.h"
#import "BleDevice.h"
#import "JUtil.h"
#import "CharacteristicCell.h"
#import "HexInputViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceViewController : UIViewController<BleManagerDelegate, UITableViewDelegate, UITableViewDataSource, HexInputViewControllerDelegate>{
    BleDevice* device;
}

-(void)setDevice:(BleDevice*)inDevice;

@end

NS_ASSUME_NONNULL_END
