//
//  BleDevice.m
//  BLE_Demo_OC
//
//  Created by 贾捷飞 on 2023/10/6.
//

#import "BleDevice.h"
#import "JUtil.h"

@implementation BleDevice

@synthesize peripheral;
@synthesize localName;
@synthesize rssi;
@dynamic name;
@dynamic deviceId;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    if (self = [super init]) {
        self.peripheral = peripheral;
        self.localName = advertisementData[CBAdvertisementDataLocalNameKey];
        self.rssi = RSSI.intValue;
        self.manufacturerData = (NSData*)advertisementData[CBAdvertisementDataManufacturerDataKey];
    }
    return self;
}

- (NSString *)name{
    return self.peripheral.name;
}

- (NSString *)deviceId{
    return self.peripheral.identifier.UUIDString;
}

- (NSString *)description
{
    NSString* mfrData = [JUtil dataToHex:self.manufacturerData];
    return [NSString stringWithFormat:@"id=%@, name=%@, localName=%@, RSSI=%d, manufacturerData=%@", self.deviceId, self.name, self.localName, self.rssi, mfrData];
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    }
    if(![other isKindOfClass:[BleDevice class]]){
        return NO;
    }
    return [self.deviceId isEqual:((BleDevice*)other).deviceId];
}

- (NSUInteger)hash
{
    return self.deviceId.hash;
}

@end
