//
//  JsonAndDictionary.m
//  owns
//
//  Created by Dongyifei on 2018/2/10.
//  Copyright © 2018年 Dongyifei. All rights reserved.
//

#import "JsonAndDictionary.h"

@implementation JsonAndDictionary

+ (NSString *)convertToJsonData:(NSDictionary *)dict{
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
//    //去掉字符串中的空格
//
//    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
//
//    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range];
    
    return mutStr;
    
}

+ (id)dataWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id data = [NSJSONSerialization JSONObjectWithData:jsonData
                                              options:NSJSONReadingMutableContainers
                                                error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return data;
}

+ (NSString *)toJSONString:(NSArray *)array{
    
    
    NSString *jsonStr = @"[";
    
    for (int i=0 ; i<array.count ; i++){
        id data = array[i];
        
        NSString *str = [self convertToJsonData:data];
        if (i != 0) {
            
            jsonStr = [jsonStr stringByAppendingString:@","];
            
        }
        
        jsonStr = [jsonStr stringByAppendingString:str];
        
    }
    
    jsonStr = [jsonStr stringByAppendingString:@"]"];
    
    
    
    return jsonStr;
    
}

+ (id)toArrayOrNSDictionary:(NSData *)jsonData{
    
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:nil];
    
    if (jsonObject != nil && error == nil){
        return jsonObject;
    }else{
        // 解析错误
        return nil;
    }
    
}

+ (id)jsonToObject:(NSString *)json{
    //string转data
    NSData * jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    //json解析
    id obj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    return obj;
}

@end
