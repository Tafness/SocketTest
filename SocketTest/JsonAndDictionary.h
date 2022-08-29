//
//  JsonAndDictionary.h
//  owns
//
//  Created by Dongyifei on 2018/2/10.
//  Copyright © 2018年 Dongyifei. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface JsonAndDictionary : NSObject

+ (NSString *)convertToJsonData:(NSDictionary *)dict;

+ (id)dataWithJsonString:(NSString *)jsonString;

+ (NSString *)toJSONString:(NSArray *)array;

+ (id)toArrayOrNSDictionary:(NSData *)jsonData;

+ (id)jsonToObject:(NSString *)json;

@end
