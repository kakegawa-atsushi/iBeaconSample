//
//  ViewController.m
//  iBeaconSamplePeripheral
//
//  Created by kakegawa.atsushi on 2013/09/25.
//  Copyright (c) 2013年 kakegawa.atsushi. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CBPeripheralManagerDelegate>

@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CBPeripheralManager *peripheralManager;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"D456894A-02F0-4CB0-8258-81C187DF45C2"];
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    if (self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        [self startAdvertising];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error) {
        [self sendLocalNotificationForMessage:[NSString stringWithFormat:@"%@", error]];
    } else {
        [self sendLocalNotificationForMessage:@"Start Advertising"];
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSString *message;
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOff:
            message = @"PoweredOff";
            break;
        case CBPeripheralManagerStatePoweredOn:
            message = @"PoweredOn";
            [self startAdvertising];
            break;
        case CBPeripheralManagerStateResetting:
            message = @"Resetting";
            break;
        case CBPeripheralManagerStateUnauthorized:
            message = @"Unauthorized";
            break;
        case CBPeripheralManagerStateUnknown:
            message = @"Unknown";
            break;
        case CBPeripheralManagerStateUnsupported:
            message = @"Unsupported";
            break;
            
        default:
            break;
    }
    
    [self sendLocalNotificationForMessage:[@"PeripheralManager did update state: " stringByAppendingString:message]];
}

#pragma mark - Private methods

- (void)startAdvertising
{
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID
                                                                           major:1
                                                                           minor:2
                                                                      identifier:@"jp.classmethod.testregion"];
    NSDictionary *beaconPeripheralData = [beaconRegion peripheralDataWithMeasuredPower:nil];
    [self.peripheralManager startAdvertising:beaconPeripheralData];
}

- (void)sendLocalNotificationForMessage:(NSString *)message
{
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.alertBody = message;
    localNotification.fireDate = [NSDate date];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
