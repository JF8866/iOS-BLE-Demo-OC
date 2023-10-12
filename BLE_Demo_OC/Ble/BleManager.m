//
//  BleManager.m
//  BLE_Demo_OC
//
//  Created by 贾捷飞 on 2023/10/6.
//

#import "BleManager.h"
#import "JUtil.h"

@implementation BleManager

static BleManager* sharedInstance = nil;

+ (instancetype)sharedInstance{
    @synchronized (self) {
        if (sharedInstance == nil) {
            sharedInstance = [[BleManager alloc] init];
            [JUtil print:@"初始化BleManager"];
        }
        return sharedInstance;
    }
}

@dynamic devices;

- (instancetype)init
{
    self = [super init];
    if (self) {
        centralManager = [[CBCentralManager alloc] init];
        centralManager.delegate = self;
        _devices = [NSMutableArray array];
        _lastServiceUuidDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSArray *)devices{
    return _devices;
}

//按信号强度排序
- (void)sortDevicesByRSSI{
    [_devices sortUsingComparator:^NSComparisonResult(BleDevice* obj1, BleDevice* obj2) {
        return obj2.rssi - obj1.rssi;
    }];
}

- (void)addDevice:(BleDevice*)device{
    NSUInteger index = [_devices indexOfObject:device];
    if (index == NSNotFound) {
        [_devices addObject:device];
    } else {
        _devices[index] = device;
    }
}

- (BleDevice*)findDevice:(NSString*)deviceId{
    for (BleDevice* device in _devices) {
        if ([device.deviceId isEqualToString:deviceId]) {
            return device;
        }
    }
    return nil;
}

- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    NSString* state = @"";
    switch (central.state) {
        case CBManagerStatePoweredOn:
            state = @"PoweredOn";
            break;
            
        case CBManagerStatePoweredOff:
            state = @"PoweredOff";
            break;
            
        case CBManagerStateResetting:
            state = @"Resetting";
            break;
        case CBManagerStateUnsupported:
            state = @"Unsupported";
            break;
            
        case CBManagerStateUnauthorized:
            state = @"Unauthorized";
            break;
                    
        case CBManagerStateUnknown:
        default:
            state = @"Unknown";
            break;
    }
    [JUtil print:[NSString stringWithFormat:@"蓝牙状态：%@", state]];
}

//扫描设备
- (void)startScan {
    if (centralManager.isScanning) {
        return;
    }
    [_devices removeAllObjects];
    [JUtil print:@"startScan()"];
    [centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}

//停止扫描
- (void)stopScan{
    [centralManager stopScan];
    [JUtil print:@"stopScan()"];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    //发现设备
    BleDevice* device = [[BleDevice alloc] initWithPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
    [self addDevice:device];
//    [JUtil print:[NSString stringWithFormat:@"发现设备 %@", device]];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(bleManager:didDiscoverDevice:)]) {
        [self.delegate bleManager:self didDiscoverDevice:device];
    }
}


//连接设备
- (void)connect:(NSString *)deviceId{
    BleDevice* device = [self findDevice:deviceId];
    if (device != nil) {
        [centralManager connectPeripheral:device.peripheral options:nil];
    }
}

//断开连接
- (void)disconnect:(NSString *)deviceId{
    BleDevice* device = [self findDevice:deviceId];
    if (device != nil) {
        [centralManager cancelPeripheralConnection:device.peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"已连接");
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"连接失败 %@", error);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"已断开 %@", error);
    peripheral.delegate = nil;
    if ([self.delegate respondsToSelector:@selector(bleManager:didDisconnectDevice:)]) {
        [self.delegate bleManager:self didDisconnectDevice:peripheral.identifier.UUIDString];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error == nil) {
        NSLog(@"发现服务");
        int count = (int)peripheral.services.count;
        for (int i = 0; i < count; i++) {
            CBService* service = peripheral.services[i];
            [peripheral discoverCharacteristics:nil forService:service];
            if (i == count - 1) {
                //记录最后一个服务的UUID，用于判断是否已获得所有的服务和特征
                _lastServiceUuidDict[peripheral.identifier.UUIDString] = service.UUID.UUIDString;
            }
        }
    } else {
        NSLog(@"获取服务失败 %@", error);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    //
    NSLog(@"Service: %@", service.UUID.UUIDString);
    for (CBCharacteristic* c in service.characteristics) {
        NSLog(@"\tCharacteristic: %@", c.UUID.UUIDString);
    }
    if ([service.UUID.UUIDString isEqual:_lastServiceUuidDict[peripheral.identifier.UUIDString]]) {
        //这样获取 MTU 貌似不准
        int mtu = (int)[peripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithoutResponse] + 3;
        NSLog(@"已获得所有的服务和特征 mtu=%d", mtu);
        //打开 Notify
        [self setNotify:peripheral.identifier.UUIDString serviceUuid:SERVICE characteristicUuid:CHARACTERISTIC_NOTIFY enabled:YES];
        
        if ([self.delegate respondsToSelector:@selector(bleManager:didConnectDevice:)]) {
            [self.delegate bleManager:self didConnectDevice:peripheral.identifier.UUIDString];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    //收到数据
    NSString* serviceUuid = characteristic.service.UUID.UUIDString;
    NSString* characteristicUuid = characteristic.UUID.UUIDString;
    NSString* hexData = [JUtil dataToHex:characteristic.value];
    NSString* strData = [JUtil dataToString:characteristic.value];
    NSUInteger length = characteristic.value.length;
    NSLog(@"收到数据 uuid=%@/%@, length=%lu, data=%@ / %@", serviceUuid, characteristicUuid, length, hexData, strData);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSString* serviceUuid = characteristic.service.UUID.UUIDString;
    NSString* characteristicUuid = characteristic.UUID.UUIDString;
    NSLog(@"通知状态变化 uuid=%@/%@, isNotifying=%d", serviceUuid, characteristicUuid, characteristic.isNotifying);
}


- (CBCharacteristic*)findCharacteristic:(BleDevice*)device serviceUuid:(NSString*)serviceUuid characteristicUuid:(NSString*)characteristicUuid{
    for (CBService* service in device.peripheral.services) {
        if ([service.UUID.UUIDString isEqual:serviceUuid]) {
            for (CBCharacteristic* c in service.characteristics) {
                if ([c.UUID.UUIDString isEqual:characteristicUuid]) {
                    return c;
                }
            }
        }
    }
    return nil;
}

//开/关 Notify
- (void)setNotify:(NSString *)deviceId serviceUuid:(NSString *)serviceUuid characteristicUuid:(NSString *)characteristicUuid enabled:(BOOL)enabled{
    BleDevice* device = [self findDevice:deviceId];
//    NSLog(@"%s device=%@", __func__, device);
    if (device != nil) {
        CBCharacteristic* characteristic = [self findCharacteristic:device serviceUuid:serviceUuid characteristicUuid:characteristicUuid];
//        NSLog(@"%s serviceUuid=%@", __func__, serviceUuid);
//        NSLog(@"%s characteristicUuid=%@", __func__, characteristicUuid);
//        NSLog(@"%s characteristic=%@", __func__, characteristic);
        if (characteristic != nil) {
            [device.peripheral setNotifyValue:enabled forCharacteristic:characteristic];
        }
    }
}

//读取数据
- (void)readCharacteristic:(NSString *)deviceId serviceUuid:(NSString *)serviceUuid characteristicUuid:(NSString *)characteristicUuid{
    BleDevice* device = [self findDevice:deviceId];
    if (device != nil) {
        CBCharacteristic* characteristic = [self findCharacteristic:device serviceUuid:serviceUuid characteristicUuid:characteristicUuid];
        if (characteristic != nil) {
            [device.peripheral readValueForCharacteristic:characteristic];
        }
    }
}

//发送数据
- (void)writeCharacteristic:(NSString *)deviceId serviceUuid:(NSString *)serviceUuid characteristicUuid:(NSString *)characteristicUuid data:(NSData *)data{
    BleDevice* device = [self findDevice:deviceId];
    if (device != nil) {
        CBCharacteristic* characteristic = [self findCharacteristic:device serviceUuid:serviceUuid characteristicUuid:characteristicUuid];
        if (characteristic != nil) {
            //优先使用无回应的写入方式
            CBCharacteristicWriteType writeType = (characteristic.properties | CBCharacteristicPropertyWriteWithoutResponse) != 0 ? CBCharacteristicWriteWithoutResponse : CBCharacteristicWriteWithResponse;
            [device.peripheral writeValue:data forCharacteristic:characteristic type:writeType];
        }
    }
}

+ (NSString *)characteristicProperties:(CBCharacteristicProperties)properties {
    NSMutableArray<NSString*>* strArr = [NSMutableArray array];
    if (properties & CBCharacteristicPropertyRead) {
        [strArr addObject:@"Read"];
    }
    if (properties & CBCharacteristicPropertyWrite) {
        [strArr addObject:@"Write"];
    }
    if (properties & CBCharacteristicPropertyNotify) {
        [strArr addObject:@"Notify"];
    }
    if (properties & CBCharacteristicPropertyIndicate) {
        [strArr addObject:@"Indicate"];
    }
    if (properties & CBCharacteristicPropertyWriteWithoutResponse) {
        [strArr addObject:@"WriteWithoutResponse"];
    }
    return [strArr componentsJoinedByString:@", "];
}

@end
