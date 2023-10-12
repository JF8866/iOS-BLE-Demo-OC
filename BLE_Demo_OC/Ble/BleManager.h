//
//  BleManager.h
//  BLE_Demo_OC
//
//  Created by 贾捷飞 on 2023/10/6.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BleDevice.h"

NS_ASSUME_NONNULL_BEGIN

//通信的UUID
static NSString* const SERVICE = @"1000";
static NSString* const CHARACTERISTIC_WRITE = @"1001";
static NSString* const CHARACTERISTIC_NOTIFY = @"1002";

@protocol BleManagerDelegate;

@interface BleManager : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>{
    CBCentralManager* centralManager;
    NSMutableArray<BleDevice*>* _devices;
    //记录最后一个服务的UUID，用于判断是否已获得所有的服务和特征
    NSMutableDictionary<NSString*, NSString*>* _lastServiceUuidDict;
}

+ (instancetype) sharedInstance;

@property(nonatomic, weak, nullable) id<BleManagerDelegate> delegate;
@property(nonatomic, readonly) NSArray* devices;

+ (NSString*)characteristicProperties:(CBCharacteristicProperties)properties;

- (void)startScan;

- (void)stopScan;

- (void)sortDevicesByRSSI;

- (BleDevice*)findDevice:(NSString*)deviceId;

- (void)connect:(NSString*)deviceId;

- (void)disconnect:(NSString*)deviceId;

- (void)setNotify:(NSString*)deviceId serviceUuid:(NSString*)serviceUuid characteristicUuid:(NSString*)characteristicUuid enabled:(BOOL)enabled;

- (void)writeCharacteristic:(NSString*)deviceId serviceUuid:(NSString*)serviceUuid characteristicUuid:(NSString*)characteristicUuid data:(NSData*)data;

- (void)readCharacteristic:(NSString*)deviceId serviceUuid:(NSString*)serviceUuid characteristicUuid:(NSString*)characteristicUuid;

@end

//委托
@protocol BleManagerDelegate <NSObject>

@optional
- (void)bleManager:(BleManager*)manager didDiscoverDevice:(BleDevice *)device;

@optional
- (void)bleManager:(BleManager*)manager didConnectDevice:(NSString *)deviceId;

@optional
- (void)bleManager:(BleManager*)manager didDisconnectDevice:(NSString *)deviceId;

@end

NS_ASSUME_NONNULL_END
