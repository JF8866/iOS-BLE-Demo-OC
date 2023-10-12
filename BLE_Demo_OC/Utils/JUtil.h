//
//  JUtil.h
//  BLE_Demo_OC
//
//  Created by 贾捷飞 on 2023/10/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JUtil : NSObject

+ (NSString*)formatDate:(NSDate*)date;

+ (void)print:(NSString*)msg;

//二进制数据转16进制字符串
+ (NSString*) dataToHex:(NSData*)data;

//16进制字符串转二进制数据
+ (NSData*) hexToData:(NSString*)hexString;

+ (NSString*)dataToString:(NSData*)data;
+ (NSData*)stringToData:(NSString*)str;

@end

NS_ASSUME_NONNULL_END
