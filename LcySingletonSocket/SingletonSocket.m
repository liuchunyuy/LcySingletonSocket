//
//  SingletonSocket.m
//  LcySingletonSocket
//
//  Created by GavinHe on 16/11/22.
//  Copyright © 2016年 Liu Chunyu. All rights reserved.
//

#import "SingletonSocket.h"

#define HOST @"140.207.101.214"
#define PORT 20213

@implementation SingletonSocket

+ (SingletonSocket *)sharedInstance
{
    static SingletonSocket *sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedInstace = [[self alloc] init];
    });
    return sharedInstace;
}

- (void)startConnectSocket
{
    self.socket = [[AsyncSocket alloc] initWithDelegate:self];
    NSError *error = nil;
    [self.socket connectToHost:HOST onPort:PORT withTimeout:20 error:&error];
}

- (NSInteger)SocketOpen:(NSString*)addr port:(NSInteger)port
{
    
    if (![self.socket isConnected])
    {
        NSError *error = nil;
        [self.socket connectToHost:addr onPort:port withTimeout:20 error:&error];
    }
    
    return 0;
}


-(void)cutOffSocket
{
    self.socket.userData = SocketOfflineByUser;
    [self.socket disconnect];
}


- (void)sendMessage:(id)message
{
    //像服务器发送数据
    NSData *cmdData = [message dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:cmdData withTimeout:-1 tag:1];
}





#pragma mark - Delegate

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    
    NSLog(@"7878 sorry the connect is failure %ld",sock.userData);
    
    if (sock.userData == SocketOfflineByServer) {
        // 服务器掉线，重连
        [self startConnectSocket];
    }
    else if (sock.userData == SocketOfflineByUser) {
        
        // 如果由用户断开，不进行重连
        return;
    }else if (sock.userData == SocketOfflineByWifiCut) {
        
        // wifi断开,重连
        [self startConnectSocket];
    }
    
}



- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSData * unreadData = [sock unreadData]; // ** This gets the current buffer
    if(unreadData.length > 0) {
        [self onSocket:sock didReadData:unreadData withTag:0]; // ** Return as much data that could be collected
    } else {
        
        NSLog(@" willDisconnectWithError %ld   err = %@",sock.userData,[err description]);
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
    // 连接成功，
    NSLog(@"didConnectToHost");
    
    //通过定时器不断发送消息，来检测长连接
    self.heartTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(checkLongConnect) userInfo:nil repeats:YES];
    [self.heartTimer fire];
}

    // 向服务器发送固定消息，检测长连接
-(void)checkLongConnect{
    
    NSString *longConnect = @"connect";
    NSData *data  = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:data withTimeout:1 tag:1];
}



//接受消息成功之后回调
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    NSLog(@"data is %@",data);
    /*
     1.data为接收到的数据
     2.通过通知，block，代理等方法传出去
     */
    
    [self.socket readDataWithTimeout:-1 tag:0];
    
}


//发送消息成功之后回调
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    //读取消息
    [self.socket readDataWithTimeout:-1 tag:0];
}


@end
