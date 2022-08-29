//
//  SocketControl.m
//  AnswerQuestionsApp
//
//  Created by 董一飞 on 2022/3/18.
//

#import "SocketControl.h"

@implementation SocketControl

+ (SocketControl *)sharedInstance{
    static SocketControl *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[SocketControl alloc] init];
    });
    return shareInstance;
}

#pragma mark - 连接socket
- (void)connectSocket{
    LGSocketServe *socketServe = [LGSocketServe sharedSocketServe];
    //socket连接前先断开连接以免之前socket连接没有断开导致闪退
    [socketServe cutOffSocket];
    socketServe.socket.userData = SocketOfflineByUser;
    
    [socketServe startConnectSocket];
}

#pragma mark - 断开socket
- (void)cutoffSocket{
    LGSocketServe *socketServe = [LGSocketServe sharedSocketServe];
    [socketServe cutOffSocket];
    socketServe.socket.userData = SocketOfflineByUser;
    
}

#pragma mark - 解析socket
- (void)receiveMessage:(NSDictionary *)dictionary{
    
    if (!dictionary){
        dictionary = @{};
    }
        
    if ([[NSString stringWithFormat:@"%@",[dictionary valueForKey:@"errcode"]] isEqualToString:@"ERROR_CHAT"]) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kSocketReceiveMessage" object:nil];
    
    NSNotification *notification = [NSNotification notificationWithName:@"kSocketReceiveMessage" object:nil userInfo:dictionary];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark - 发送socket
- (void)sendMessageJson:(NSString *)json{
    
    LGSocketServe *socketServe = [LGSocketServe sharedSocketServe];
    
    [socketServe sendMessage:[NSString stringWithFormat:@"%@\n",json]];
}

#pragma mark - 最外层封装返回json
- (NSString *)packageSendMessageWithData:(NSDictionary *)data{
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    [param setObject:data forKey:@"data"];
    
    ;
    NSString *json = [NSString stringWithFormat:@"%@\n",[JsonAndDictionary convertToJsonData:param]];
    
    return json;
}


@end
