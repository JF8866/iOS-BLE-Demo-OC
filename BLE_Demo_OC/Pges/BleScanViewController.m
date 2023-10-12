//
//  BleScanViewController.m
//  BLE_Demo_OC
//
//  Created by 贾捷飞 on 2023/10/6.
//

#import "BleScanViewController.h"
#import "JUtil.h"
#import "BleManager.h"
#import "DeviceCell.h"

@interface BleScanViewController ()
{
    BleDevice* device;//记录连接的设备，用于断开连接
}
@end

@implementation BleScanViewController

- (IBAction)sortDevices:(id)sender {
    //排序
    [BleManager.sharedInstance sortDevicesByRSSI];
    [self.tableView reloadData];
}

- (void)startScan {
    //开始扫描设备
    [BleManager.sharedInstance startScan];
    //扫描设备会清空设备列表，这里是刷新一下tableView
    [self.tableView reloadData];
    //3秒后停止扫描
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //终止“正在刷新”的状态
        [self.tableView.refreshControl endRefreshing];
        //停止扫描设备
        [BleManager.sharedInstance stopScan];
    });
}

- (void)bleManager:(BleManager *)manager didDiscoverDevice:(BleDevice *)device{
    //每次扫到设备都会刷新 BleManager.sharedInstance.devices，这里刷新一下tableView
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"%s", __func__);
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 65;

    UIRefreshControl* rc = [UIRefreshControl new];
    NSAttributedString* refreshTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    rc.attributedTitle = refreshTitle;
    [rc addTarget:self action:@selector(startScan) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = rc;
}

- (void)viewDidAppear:(BOOL)animated {
    BleManager.sharedInstance.delegate = self;//初始化
    [BleManager.sharedInstance disconnect:device.deviceId];//断开连接
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return BleManager.sharedInstance.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceCell* cell = [tableView dequeueReusableCellWithIdentifier:@"deviceCell" forIndexPath:indexPath];
    BleDevice* device = BleManager.sharedInstance.devices[indexPath.row];
    NSString* mfrDataHex = [JUtil dataToHex:device.manufacturerData];
    cell.labelLocalName.text = device.localName;
    cell.labelDeviceID.text = device.deviceId;
    cell.labelManufacturerData.text = [NSString stringWithFormat:@"Manufacturer Data: %@", mfrDataHex];
    cell.labelRSSI.text = [NSString stringWithFormat:@"%d", device.rssi];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqual:@"showDeviceViewController"]) {
        DeviceViewController* controller = [segue destinationViewController];
        NSUInteger index = self.tableView.indexPathForSelectedRow.row;
        device = BleManager.sharedInstance.devices[index];
        [controller setDevice:device];
    }
}

@end
