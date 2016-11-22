//
//  ViewController.m
//  LcySingletonSocket
//
//  Created by GavinHe on 16/11/22.
//  Copyright © 2016年 Liu Chunyu. All rights reserved.
//

#import "ViewController.h"
#import "SingletonSocket.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //连接前，先手动断开
    [[SingletonSocket sharedInstance] cutOffSocket];
    [SingletonSocket sharedInstance].socket.userData = SocketOfflineByServer;
    
    [[SingletonSocket sharedInstance] startConnectSocket];
    
    /*
     1. 向服务器发送信息，例如：登录指令的data数据
     2.登录成功后，这里可以通过通知，block，代理接收到 SingletonSoket.m 中接收到的数据进行解析
     */
    [[SingletonSocket sharedInstance] sendMessage:@"login"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
