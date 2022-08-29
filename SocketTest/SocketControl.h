//
//  SocketControl.h
//  AnswerQuestionsApp
//
//  Created by 董一飞 on 2022/3/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SocketSendType){
    /// 连接
    SocketSendTypeConnect,
    
    SocketSendTypeSendMessage,

};

@interface SocketControl : NSObject

+ (SocketControl *)sharedInstance;

@property (nonatomic, copy) NSString *socketUrl;

@property (nonatomic, assign) NSInteger port;

/// 连接socket
- (void)connectSocket;

/// 断开socket
- (void)cutoffSocket;

/// 接收socket消息并解析
- (void)receiveMessage:(NSDictionary *)dictionary;

/// 发送socket消息
- (void)sendMessageJson:(NSString *)json;

@end

/**
 * 参数解释
 *
 * sn : 设备唯一码 app自主生成
 * app_cate : APP类型
 * mode : 指令名称
 *
 */
/**
 * app_cate :
 *
 * spb 英文拼词
 * shici 诗词大赛
 */

/**
 * mode :
 *
 * register_device 注册/更新设备
 * check_app 校验APP版本 (可选)
 * check_testpaper 校验题库
 * sync_testpaper 同步题库 (可选)
 * upload_score 上传成绩
 */


NS_ASSUME_NONNULL_END
