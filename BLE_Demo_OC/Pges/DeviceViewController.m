//
//  DeviceViewController.m
//  BLE_Demo_OC
//
//  Created by 贾捷飞 on 2023/10/8.
//

#import "DeviceViewController.h"

@interface DeviceViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(weak, nonatomic) NSMutableArray<NSArray*>* characteristics;

@property(weak, nonatomic) CBCharacteristic* currentCharacteristic;

@end

@implementation DeviceViewController

- (void)setDevice:(BleDevice *)inDevice{
    device = inDevice;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = device.localName;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [BleManager.sharedInstance connect:device.deviceId];//连接设备
}

- (void)viewDidAppear:(BOOL)animated {
    BleManager.sharedInstance.delegate = self;//初始化
}


- (void)viewDidDisappear:(BOOL)animated {
    
}

- (void)bleManager:(BleManager *)manager didConnectDevice:(NSString *)deviceId {
    NSLog(@"%s 已连接", __func__);
    [self.tableView reloadData];
}

- (void)bleManager:(BleManager *)manager didDisconnectDevice:(NSString *)deviceId {
    NSLog(@"%s 已断开", __func__);
}

- (void)readCharacteristic:(UIButton*)button {
//    NSLog(@"%s", __func__);
    CBCharacteristic* characteristic = [self getItem:button];
    [device.peripheral readValueForCharacteristic:characteristic];
}

- (void)writeCharacteristic:(UIButton*)button {
//    NSLog(@"%s", __func__);
    CBCharacteristic* characteristic = [self getItem:button];
    [device.peripheral writeValue:[JUtil hexToData:@"55AAaa55"] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void)notifyCharacteristic:(UISwitch*)button {
//    NSLog(@"%s on=%d", __func__, button.on);
    CBCharacteristic* characteristic = [self getItem:button];
    [device.peripheral setNotifyValue:button.on forCharacteristic:characteristic];
}

- (CBCharacteristic*) getItem:(UIControl*)button {
    //查找 button 对应的 UITableViewCell
    UIView* cell = button.superview;
    do {
        cell = cell.superview;
    } while (![cell isKindOfClass:[UITableViewCell class]]);
    //获取 UITableViewCell 对应的 indexPath
    NSIndexPath* indexPath = [self.tableView indexPathForCell:(UITableViewCell*)cell];
//    NSLog(@"section=%ld, row=%ld", indexPath.section, indexPath.row);
    CBService* service = device.peripheral.services[indexPath.section];
    self.currentCharacteristic = service.characteristics[indexPath.row];
    return self.currentCharacteristic;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([@"showHexViewController" isEqualToString:segue.identifier]) {
        HexInputViewController* controller = segue.destinationViewController;
        controller.delegate = self;
    }
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath { 
    CharacteristicCell* cell = [tableView dequeueReusableCellWithIdentifier:@"characteristicCell" forIndexPath:indexPath];
    CBCharacteristic* item = device.peripheral.services[indexPath.section].characteristics[indexPath.row];
    cell.labelUUID.text = item.UUID.UUIDString;
    cell.labelProperties.text = [BleManager characteristicProperties:item.properties];
    [cell.buttonRead setHidden:(item.properties & CBCharacteristicPropertyRead) == 0];
    [cell.buttonWrite setHidden:(item.properties & CBCharacteristicPropertyWrite) == 0 && (item.properties & CBCharacteristicPropertyWriteWithoutResponse) == 0];
    [cell.switchNotify setHidden:(item.properties & CBCharacteristicPropertyNotify) == 0];
    
    //先移除事件
    [cell.buttonRead removeTarget:self action:@selector(readCharacteristic:) forControlEvents:UIControlEventTouchUpInside];
    [cell.buttonWrite removeTarget:self action:@selector(writeCharacteristic:) forControlEvents:UIControlEventTouchUpInside];
    [cell.switchNotify removeTarget:self action:@selector(notifyCharacteristic:) forControlEvents:UIControlEventValueChanged];
    
    //然后设置控件状态
    [cell.switchNotify setOn:item.isNotifying];
    
    //最后添加事件
    [cell.buttonRead addTarget:self action:@selector(readCharacteristic:) forControlEvents:UIControlEventTouchUpInside];
    [cell.buttonWrite addTarget:self action:@selector(writeCharacteristic:) forControlEvents:UIControlEventTouchUpInside];
    [cell.switchNotify addTarget:self action:@selector(notifyCharacteristic:) forControlEvents:UIControlEventValueChanged];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return device.peripheral.services[section].characteristics.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return device.peripheral.services.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    CBService* service = device.peripheral.services[section];
//    NSLog(@"%@ %@", service.UUID.UUIDString, service.UUID.description);
    return [NSString stringWithFormat:@"%@", service.UUID.UUIDString];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0;
}

- (void)hexInputDone:(NSString *)hexString{
    NSData* data = [JUtil hexToData:hexString];
    CBCharacteristicWriteType writeType = (self.currentCharacteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) ? CBCharacteristicWriteWithoutResponse:CBCharacteristicWriteWithResponse;
    [device.peripheral writeValue:data forCharacteristic:self.currentCharacteristic type:writeType];
}

@end
