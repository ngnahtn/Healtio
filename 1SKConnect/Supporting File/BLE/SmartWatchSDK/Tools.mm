//
//  Tools.m
//  KeepHealth
//
//  Created by wangjun on 2019/4/18.
//  Copyright © 2019 zhihuiju. All rights reserved.
//

#import "Tools.h"

//#import "JZLocationConverter.h"

@implementation Tools
+ (NSString *)getCurrentLanguage
{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    return currentLanguage;
}


/** 获取当前是星期几 把当前日期变成星期 */
+ (NSInteger)getNowWeekday {
    NSDate *date = [NSDate date];
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]; // 指定日历的算法
    NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:date];
    NSInteger week = [comps weekday];
    return week;
}

/**
 若是中文直接转拼音
 */
+ (NSString *)transformPinyin:(NSString *)chinese
{
    if (![Tools isChinese:chinese]) {
        return chinese;
    }
    NSMutableString *pinyin = [chinese mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    //去掉空格
    return [[NSString stringWithFormat:@"%@",pinyin] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

/**
 检测是否是中文
 */
+(BOOL)isChinese:(NSString *)str
{
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:str];
}

+ (void)writeToFileWithString:(NSString*)string withFileName:(NSString*)fileName{
    NSString* fileName1 = [[self class] filePath:fileName];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* str = nil;
    if ([fileManager fileExistsAtPath:fileName1]) {
        
        
        NSData* data = [NSData dataWithContentsOfFile:fileName1];
        
        //设置文件超过500K就清空
        if (data.length>1024*500) {
            string = [NSString stringWithFormat:@"%@",string];
        }
        else{
            str =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            string = [NSString stringWithFormat:@"%@\n%@",str,string];
        }
    }
    
    [fileManager createFileAtPath:fileName1 contents:[string dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

+ (void)deleteFilewithFileName:(NSString*)fileName{
    NSString* fileName1 = [[self class] filePath:fileName];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fileName1]) {
        NSError *err;
        [fileManager removeItemAtPath:fileName1 error: &err];
    }
}


//写入本地文件
+ (NSString*)filePath:(NSString*)fileName {
    NSArray* myPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* myDocPath = [myPaths objectAtIndex:0];
    NSString* filePath = [myDocPath stringByAppendingPathComponent:fileName];
    return filePath;
}


/**
 本地语言转换
 
 @param language 系统语言
 */
+(NSString*)laguageTransform:(NSString*)language
{
    NSDictionary * dict =@{@"zh-Hans-CN":@"zh_CN",//    zh-Hans-CN, 简体中文
                           @"zh-Hant-HK":@"zh_TW",//    zh-Hant-HK, 香港繁体
                           @"zh-Hant-HK":@"zh_TW",//    zh-Hant-CN, 繁体中文
                           @"zh-Hant-MO":@"zh_TW",//    zh-Hant-MO, 繁体中文(澳门)
                           @"zh-Hant-TW":@"zh_TW",//    zh-Hant-TW  繁体中文(台湾)
                           @"en-CN":@"en_US",     //    en-CN,      英文
                           @"en-AU":@"en_US",     //    en-AU,      英文(澳大利亚)
                           @"en-IN":@"en_US",     //    en-IN,      英文(印度)
                           @"en-GB":@"en_GB",     //    en-GB,      英文(英国)
                           @"es-CN":@"es_SA",     //    es-CN,      西班牙
                           @"es-419":@"es_SA",    //    es-419,     西班牙(拉丁美洲)
                           @"es-MX":@"es_SA",     //    es-MX,      西班牙(墨西哥)
                           @"de-AT":@"de_DE",     //    de-AT,      德文(奥地利)
                           @"de-CN":@"de_DE",     //    de-CN,      德文
                           @"de-DE":@"de_DE",     //    de-DE,      德文(德国)
                           @"de-CH":@"de_DE",     //    de-CH,      德文(瑞士)
                           @"fr-BE":@"fr_FR",     //    fr-BE,      法文(比利时)
                           @"fr-FR":@"fr_FR",     //    fr-FR,      法文(法国)
                           @"fr-CH":@"fr_FR",     //    fr-CH,      法文(瑞士)
                           @"fr-CA":@"fr_FR",     //    fr-CA,      法文(加拿大)
                           @"fr-CN":@"fr_FR",     //    fr-CN,      法文
                           @"pt-PT":@"pt_PT",     //    pt-PT,      葡萄牙文
                           @"pt-BR":@"pt_BZ",     //    pt-BR,      葡萄牙(巴西)
                           @"ko-CN":@"ko",        //    ko-CN,      韩文
                           @"ja-CN":@"ja_JP",     //    ja-CN,      日文
                           @"ru-CN":@"ru_RU",     //    ru-CN       俄文
                           @"ro-CN":@"ro_RO",     //    ro-CN,      罗马尼亚
                           @"it_CN":@"it_IT",     //    it-CN,      意大利
                           @"el_CN":@"el_GR",     //    el-CN,      希腊文
                           @"tr-CN":@"tr-TR"      //    tr-CN,      土耳其
                           };
    NSArray * dictKeyArray = [dict allKeys];
    if ([dictKeyArray containsObject:language])
    {
        return dict[language];
    };
    return nil;
}

/**
 获取时间戳
 
 @param date 日期
 @param hour 小时
 @param minute 分钟
 @param seconds 秒
 @return 时间戳
 */
+ (NSInteger)zeroOfSecondsTimestampWithDate:(NSDate *)date hour:(NSInteger)hour minute:(NSInteger)minute seconds:(NSInteger)seconds
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:[NSDate date]];
    components.hour = hour;
    components.minute = minute;
    components.second = seconds;
    NSTimeInterval ts = (NSInteger)[[calendar dateFromComponents:components] timeIntervalSince1970];
    return ts;
}

/**
 获取时间戳
 
 @param time 2017-01-01-12-12-12格式的时间
 @return 时间戳字符串
 */
+ (NSString *)getTimestampWithTime:(NSString *)time{
    
    if (!time.length) {
        return @"";
    }
    
    NSArray *arr = [time componentsSeparatedByString:@"-"];
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setCalendar: [[NSCalendar alloc]
                                  initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
//    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    switch (arr.count) {
        case 3:
            [inputFormatter setDateFormat:@"yyyy-MM-dd"];
            break;
            
        case 4:
            [inputFormatter setDateFormat:@"yyyy-MM-dd-HH"];
            break;
            
        case 5:
            [inputFormatter setDateFormat:@"yyyy-MM-dd-HH-mm"];
            break;
            
            
        case 6:
            [inputFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
            break;
            
            
        default:
            break;
    }
    
    NSDate* inputDate = [inputFormatter dateFromString:time];
    NSLog(@"date = %@", inputDate);
    
    NSString *timestamp = [NSString stringWithFormat:@"%ld",(long)[inputDate timeIntervalSince1970]];
    return timestamp;
}

+ (int)heartRateGrade:(NSInteger)heartRate
{
    if (heartRate >= 150 && heartRate<= 180) {
        return 3;
    }else if (heartRate >= 120 && heartRate< 150){
        return 2;
    }else if (heartRate < 120){
        return 1;
    }
    return 1;
}

/**
 将步数转换为卡路里,公里(此算法与手环算法一致)
 
 @param steps 步数
 @param type  0:卡路里 1:公里
 */
+ (NSString *)stepsConversionCaloriesAndKmStpes:(NSString *)steps type:(NSInteger)type {
    if (!steps.integerValue) {
        return @"0";
    }
    // 卡路里跟公里数根据计算(与手环计算公式一致)
    if (type) {
        // 公里 = 步数*(0.415*身高)/100000
        NSInteger height = 175;
        return [NSString stringWithFormat:@"%.3f",steps.integerValue * (0.415 * height) / 100000];
    }
    // 卡路里 = 步数 *（（体重- 15）* 0.000693 + 0.005895）
    CGFloat weight = 65.0;
    return [NSString stringWithFormat:@"%.3f",steps.integerValue * ((weight - 15) * 0.000693 + 0.005895)];
}

/**
 将周期字符串转成对应日期字符串（1100000-周一，周二）
 */
+ (NSString *)cycleStrConversion:(NSString *)cycleStr {
    
    NSArray *cycleArr = @[NSLocalizedString(@"周一 ", nil),
                          NSLocalizedString(@"周二 ", nil),
                          NSLocalizedString(@"周三 ", nil),
                          NSLocalizedString(@"周四 ", nil),
                          NSLocalizedString(@"周五 ", nil),
                          NSLocalizedString(@"周六 ", nil),
                          NSLocalizedString(@"周日 ", nil)];
    NSMutableString *tempStr = [[NSMutableString alloc] init];
    
    for (int i = 0; i < 7; i++) {
        
        if ([[cycleStr substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"1"]) {
            [tempStr appendString:cycleArr[i]];
        }
    }
    return tempStr.length ? (NSString *)tempStr : NSLocalizedString(@"仅一次", nil);
}

+ (NSString *)stringDecode:(NSString *)str {
    NSString *result = [(NSString *)str stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

///16进制字符串转data
+ (NSData *)convertHexStrToData:(NSString *)str
{
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:20];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

// 将NSLog打印信息保存到Document目录下的文件中
+ (void)redirectNSlogToDocumentFolder
{
    NSString *logFilePath = [[self class] logFilePath];
    // 将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
//    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdin);
}

//取得log文件路径
+ (NSString *)logFilePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSString *fileName = [NSString stringWithFormat:@"%@.log",[[NSDate alloc] initWithTimeIntervalSinceNow:8*3600]]; // 注意不是NSData!
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    return logFilePath;
}

// 判断当前是否是12小时制
+ (BOOL)is12HourFormat{
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA =[formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM =containsA.location != NSNotFound;
    return hasAMPM;
}
//获取scrollview的内容截图
+ (UIImage *)captureScrollView:(UIScrollView *)scrollView{
    UIImage* image = nil;
    //  第一个参数表示区域大小。第二个参数表示是否是非透明的,一般传no。第三个参数就是屏幕密度了，关键就是第三个参数
    UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, NO, [UIScreen mainScreen].scale);
    {
        CGPoint savedContentOffset = scrollView.contentOffset;
        CGRect savedFrame = scrollView.frame;
        scrollView.contentOffset = CGPointZero;
        scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
        [scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        scrollView.contentOffset = savedContentOffset;
        scrollView.frame = savedFrame;
    }
    UIGraphicsEndImageContext();
    if (image != nil) {
        return image;
    }
    return nil;
}
@end
