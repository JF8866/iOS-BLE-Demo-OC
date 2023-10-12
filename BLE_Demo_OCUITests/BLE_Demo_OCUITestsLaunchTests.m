//
//  BLE_Demo_OCUITestsLaunchTests.m
//  BLE_Demo_OCUITests
//
//  Created by 贾捷飞 on 2023/10/6.
//

#import <XCTest/XCTest.h>

@interface BLE_Demo_OCUITestsLaunchTests : XCTestCase

@end

@implementation BLE_Demo_OCUITestsLaunchTests

+ (BOOL)runsForEachTargetApplicationUIConfiguration {
    return YES;
}

- (void)setUp {
    self.continueAfterFailure = NO;
}

- (void)testLaunch {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];

    // Insert steps here to perform after app launch but before taking a screenshot,
    // such as logging into a test account or navigating somewhere in the app

    XCTAttachment *attachment = [XCTAttachment attachmentWithScreenshot:XCUIScreen.mainScreen.screenshot];
    attachment.name = @"Launch Screen";
    attachment.lifetime = XCTAttachmentLifetimeKeepAlways;
    [self addAttachment:attachment];
}

@end
