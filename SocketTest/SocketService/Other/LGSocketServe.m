//
//  LGSocketServe.m
//  AsyncSocketDemo
//
//  Created by ligang on 15/4/3.
//  Copyright (c) 2015年 ligang. All rights reserved.
//

#import "LGSocketServe.h"
#import <AudioToolbox/AudioToolbox.h>
//设置连接超时
#define TIME_OUT -1

//设置读取超时 -1 表示不会使用超时
#define READ_TIME_OUT -1

//设置写入超时 -1 表示不会使用超时
#define WRITE_TIME_OUT -1

//每次最多读取多少
#define MAX_BUFFER 102400000

@interface LGSocketServe ()
@property (nonatomic, strong) NSString *messageSurplusString;//当前消息后半段不能解析的字符串，用来拼到下一条消息中
@end
@implementation LGSocketServe{
    NSString *friendID;
}


static LGSocketServe *socketServe = nil;

#pragma mark public static methods


+ (LGSocketServe *)sharedSocketServe {
    @synchronized(self) {
        if(socketServe == nil) {
            socketServe = [[[self class] alloc] init];
        }
    }
    return socketServe;
}


+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self)
    {
        if (socketServe == nil)
        {
            socketServe = [super allocWithZone:zone];
            return socketServe;
        }
    }
    return nil;
}


- (void)startConnectSocket {
    self.socket = [[AsyncSocket alloc] initWithDelegate:self];
    
    [self.socket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    
    if (![self SocketOpen:[SocketControl sharedInstance].socketUrl port:[SocketControl sharedInstance].port]){
        
    }
}


- (void)logOutSocket {
    NSLog(@"socket登出");
    
    [self performSelector:@selector(cutOffSocket) withObject:nil afterDelay:1.0];
}

- (NSInteger)SocketOpen:(NSString*)addr port:(NSInteger)port
{
    
    if (![self.socket isConnected])
    {
        NSError *error = nil;
        [self.socket connectToHost:addr onPort:port withTimeout:TIME_OUT error:&error];
    }
    
    return 0;
}


- (void)cutOffSocket
{
    self.socket.userData = SocketOfflineByUser;
    [self.socket disconnect];
}


- (void)sendMessage:(id)message
{
        
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    //像服务器发送数据
    NSData *cmdData = [message dataUsingEncoding:gbkEncoding];
    
    [self.socket writeData:cmdData withTimeout:WRITE_TIME_OUT tag:1];
}

#pragma mark - Delegate

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
        
    if (sock.userData == SocketOfflineByServer) {
        // 服务器掉线，重连
        [self startConnectSocket];
    }
    else if (sock.userData == SocketOfflineByUser) {
        
        // 如果由用户断开，不进行重连
        return;
    }else if (sock.userData == SocketOfflineByWifiCut) {
        
        // wifi断开，进行重连
        [self startConnectSocket];
        return;
    }
}



- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSData * unreadData = [sock unreadData]; // ** This gets the current buffer
    if(unreadData.length > 0) {
        [self onSocket:sock didReadData:unreadData withTag:0]; // ** Return as much data that could be collected
    } else {
        
        //  NSLog(@" willDisconnectWithError %ld   err = %@",sock.userData,[err description]);
        if (err.code == 57) {
            self.socket.userData = SocketOfflineByWifiCut;
        }
    }
    
}



- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    NSLog(@"didAcceptNewSocket");
}


- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    //这是异步返回的连接成功，
    NSLog(@"didConnectToHost");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kSocketConnectSuccess" object:nil];
    
    NSNotification *notification = [NSNotification notificationWithName:@"kSocketConnectSuccess" object:nil userInfo:@{}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    //通过定时器不断发送消息，来检测长连接
    if(self.heartTimer==nil){
        self.heartTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(checkLongConnectByServe) userInfo:nil repeats:YES];
        [self.heartTimer fire];
    }
}

// 心跳连接
-(void)checkLongConnectByServe{
    //{"T":"0"}
    NSString *longConnect = [NSString stringWithFormat:@"{\"type\":\"ping\"}\n"];
     //向服务器发送固定可是的消息，来检测长连接

    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData   *data  = [longConnect dataUsingEncoding:gbkEncoding];
    [self.socket writeData:data withTimeout:4 tag:1];
//    NSLog(@"心跳");
}


//接受消息成功之后回调
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    //服务端返回消息数据量比较大时，可能分多次返回。所以在读取消息的时候，设置MAX_BUFFER表示每次最多读取多少，当data.length < MAX_BUFFER我们认为有可能是接受完一个完整的消息，然后才解析
    if( data.length < MAX_BUFFER )
    {
        
//        NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//
//        NSString *result = [[NSString alloc] initWithData:data encoding:gbkEncoding];
//
//        //gbkEncoding没解析出来的消息用NSUTF8StringEncoding再次解析一遍
//        if(!result){
//            result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        }
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if (!result) {
            return;
        }
        
        if ([result hasPrefix:@"{"] && [result hasSuffix:@"}\n"]) {
            
            [self receiveMessage:result];
            
        } else {
            if ([result hasPrefix:@"{"]) {
                
                self.messageSurplusString = result;
                
            } else if ([result hasSuffix:@"}\n"]) {
                
                self.messageSurplusString = [self.messageSurplusString stringByAppendingString:result];
                
                [self receiveMessage:self.messageSurplusString];
                
            } else {
                
                self.messageSurplusString = [self.messageSurplusString stringByAppendingString:result];
                
            }
        }
        /*
        //将上一条信息粘包的部分与此条消息拼凑成一个完整的socket消息
        if(![result hasPrefix:@"{"] && self.messageSurplusString){
            result = [self.messageSurplusString stringByAppendingString:result];
            self.messageSurplusString = nil;
        }
        
        NSArray *results = [result componentsSeparatedByString:@"\n"];
        
        for (NSString *message in results){
            if(NULLString(message))continue;
            
            if(!NULLString([results lastObject])){
                self.messageSurplusString = [results lastObject];
            }
            
            NSData *resultData = [message dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableLeaves error:nil];
            
            BLYLogInfo(@"%@",dic);
            
            if([dic[@"code"] intValue] == 500){
                DEBUGHUD(@"连接socket的时候，几个id为空或者是0");
            }
            
            ////集中到SocketControl类中处理
            [[SocketControl sharedInstance] receiveMessage:dic];

        }
        */
    }
    else{
        //长度超出
    }
    
    
    [self.socket readDataWithTimeout:READ_TIME_OUT buffer:nil bufferOffset:0 maxLength:MAX_BUFFER tag:0];
    
}



//发送消息成功之后回调
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    //读取消息
    [self.socket readDataWithTimeout:-1 buffer:nil bufferOffset:0 maxLength:MAX_BUFFER tag:0];
}

- (void)receiveMessage:(NSString *)message{
    
    NSArray *messages = [message componentsSeparatedByString:@"\n"];
    
    for (NSString *singleMessage in messages) {
        if (NULLString(singleMessage)) continue;
        
        NSData *resultData = [singleMessage dataUsingEncoding:NSUTF8StringEncoding];
        
        if (!resultData) continue;
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableLeaves error:nil];
        
        if (!dic) continue;
        
        [[SocketControl sharedInstance] receiveMessage:dic];
    }
    
}

@end
