//
//  JUtil.m
//  BLE_Demo_OC
//
//  Created by 贾捷飞 on 2023/10/6.
//

#import "JUtil.h"

@implementation JUtil

static const NSDateFormatter* dateFormatter;

+ (void)initialize
{
    if (self == [JUtil class]) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    }
}

+ (NSString *)formatDate:(NSDate *)date{
    return [dateFormatter stringFromDate:date];
}

+ (void)print:(NSString*)msg{
    NSLog(@"%@ - %@", [JUtil formatDate:NSDate.date], msg);
}

+ (NSString *)dataToHex:(NSData *)data{
    if(data == nil){
        return nil;
    }
    NSUInteger len = [data length];
    Byte* bytes = (Byte*)data.bytes;
    NSMutableArray* hexArr = [NSMutableArray array];
    for (int i = 0; i < len; i++) {
        [hexArr addObject:[NSString stringWithFormat:@"%02X", bytes[i]]];
    }
    return [hexArr componentsJoinedByString:@" "];
}

+ (NSData *)hexToData:(NSString *)hexString{
    hexString = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSUInteger len = [hexString length] / 2;
    Byte bytes[len];
    char** endptr = NULL;
    for (int i = 0; i < len; i++) {
        bytes[i] = strtoul([[hexString substringWithRange:NSMakeRange(i*2, 2)] UTF8String], endptr, 16);
    }
    return [NSData dataWithBytes:bytes length:len];
}

+ (NSString *)dataToString:(NSData *)data{
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSData *)stringToData:(NSString *)str{
    return [str dataUsingEncoding:NSUTF8StringEncoding];
}

@end
