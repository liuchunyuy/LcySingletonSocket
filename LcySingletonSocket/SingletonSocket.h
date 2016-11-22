//
//  SingletonSocket.h
//  LcySingletonSocket
//
//  Created by GavinHe on 16/11/22.
//  Copyright © 2016年 Liu Chunyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

enum{
    SocketOfflineByServer,      //服务器掉线
    SocketOfflineByUser,        //用户断开
    SocketOfflineByWifiCut,     //wifi 断开
};
@interface SingletonSocket : NSObject<AsyncSocketDelegate>

@property(nonatomic,strong)AsyncSocket *socket;
@property(nonatomic,retain)NSTimer *heartTimer;

+(SingletonSocket *)sharedInstance;
-(void)startConnectSocket;
-(void)cutOffSocket;
-(void)sendMessage:(id)message;
@end
