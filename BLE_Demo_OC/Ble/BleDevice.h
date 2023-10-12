//
//  BleDevice.h
//  BLE_Demo_OC
//
//  Created by 贾捷飞 on 2023/10/6.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface BleDevice : NSObject

@property(nonatomic, retain) CBPeripheral* peripheral;
@property(nonatomic, retain) NSString* localName;
@property(nonatomic) int rssi;
@property(nonatomic, readonly) NSString* name;
@property(nonatomic, readonly) NSString* deviceId;
@property(nonatomic, copy) NSData* manufacturerData;

- (instancetype)initWithPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI;

@end

NS_ASSUME_NONNULL_END
