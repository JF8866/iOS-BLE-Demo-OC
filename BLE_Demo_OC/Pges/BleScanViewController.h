//
//  BleScanViewController.h
//  BLE_Demo_OC
//
//  Created by 贾捷飞 on 2023/10/6.
//

#import <UIKit/UIKit.h>
#import "BleManager.h"
#import "BleDevice.h"
#import "DeviceViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BleScanViewController : UITableViewController<BleManagerDelegate>

@end

NS_ASSUME_NONNULL_END
