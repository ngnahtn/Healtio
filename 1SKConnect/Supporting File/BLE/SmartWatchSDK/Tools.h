//
//  Tools.h
//  KeepHealth
//
//  Created by wangjun on 2019/4/18.
//  Copyright © 2019 zhihuiju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Tools : NSObject
+ (NSString *)getCurrentLanguage;

/** 获取当前是星期几 把当前日期变成星期 */
+ (NSInteger)getNowWeekday;
/**
 若是中文直接转拼音
 */
+ (NSString *)transformPinyin:(NSString *)chinese;
+ (void)deleteFilewithFileName:(NSString*)fileName;
+ (void)writeToFileWithString:(NSString*)string withFileName:(NSString*)fileName;
/**
 两个时间差(分钟)
 
 @param startTime 开始时间
 @param endTime 结束时间
 @return 分钟 (字符串)
 */
+(NSString *)compareStartTime:(NSString *)startTime EndTime:(NSString *)endTime;
/**
 本地语言转换
 
 @param language 系统语言
 */
+(NSString*)laguageTransform:(NSString*)language;
/**
 获取时间戳
 
 @param date 日期
 @param hour 小时
 @param minute 分钟
 @param seconds 秒
 @return 时间戳
 */
+ (NSInteger)zeroOfSecondsTimestampWithDate:(NSDate *)date hour:(NSInteger)hour minute:(NSInteger)minute seconds:(NSInteger)seconds;


/**
 获取时间戳
 
 @param time 2017-01-01-12-12-12格式的时间
 @return 时间戳字符串
 */
+ (NSString *)getTimestampWithTime:(NSString *)time;
/**
 训练强度计算
 
 @param heartRate 心率数值
 @return 训练强度等级
 */
+ (int)heartRateGrade:(NSInteger)heartRate;
/**
 将步数转换为卡路里,公里(此算法与手环算法一致)
 
 @param steps 步数
 @param type  0:卡路里 1:公里
 */
+ (NSString *)stepsConversionCaloriesAndKmStpes:(NSString *)steps type:(NSInteger)type;

/**
 将周期字符串转成对应日期字符串（1100000-周一，周二）
 */
+ (NSString *)cycleStrConversion:(NSString *)cycleStr;

+ (NSString *)stringDecode:(NSString *)str;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
/// 16进制字符串转data
+ (NSData *)convertHexStrToData:(NSString *)str;
// 将NSLog打印信息保存到Document目录下的文件中
+ (void)redirectNSlogToDocumentFolder;
//取得log文件路径
+ (NSString *)logFilePath;
// 判断当前是否是12小时制
+ (BOOL)is12HourFormat;
//获取scrollview的内容截图
+ (UIImage *)captureScrollView:(UIScrollView *)scrollView;

@end
