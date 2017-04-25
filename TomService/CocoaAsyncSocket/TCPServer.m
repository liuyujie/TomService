//
//  TCPServer.m
//  TomService
//
//  Created by CodingTom on 2017/4/25.
//  Copyright © 2017年 CodingTom. All rights reserved.
//

#import "TCPServer.h"
#import "SocketServerManager.h"


@interface TCPServer()<SocketServerManagerDelegate>
{

}
@property (strong, nonatomic) dispatch_queue_t APIQueue;
@property (strong, nonatomic) dispatch_semaphore_t semaphore;       // seq 同步信号
@property (assign, nonatomic) UInt32 seq;
@property (strong, nonatomic) NSMutableDictionary *callbackBlock;   // 保存请求回调 {seq: block}, 超时要踢掉
@property (strong, nonatomic) NSLock *dictionaryLock;
@property (strong, nonatomic) NSMutableData *buffer;            // 接收缓冲区

@end

@implementation TCPServer

static TCPServer *instance = nil;

+ (TCPServer *)instance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TCPServer alloc] init];
    });
    return instance;
}

- (UInt32)seq {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    _seq = _seq + 1;
    dispatch_semaphore_signal(self.semaphore);
    return _seq;
}

- (instancetype)init {
    if (self = [super init]) {
        [SocketServerManager instance].delegate = self;       // 创建 socket
        [[SocketServerManager instance] startServerWithPort:5866];
        self.semaphore = dispatch_semaphore_create(1);
        self.APIQueue = dispatch_queue_create("tom.server.api", DISPATCH_QUEUE_SERIAL);
        self.seq = 1000;
        self.dictionaryLock = [[NSLock alloc] init];
        self.callbackBlock = [[NSMutableDictionary alloc] init];
        self.buffer = [[NSMutableData alloc] init];
        [self.buffer setLength:0];
    }
    return self;
}


- (void)sendTomMessage:(TOMMessageModel *)messageModel Socket:(GCDAsyncSocket *)socket completion:(TCPBlock)block
{
    dispatch_async(self.APIQueue, ^{
        UInt32 tag = self.seq;
        messageModel.tag = tag;
        [self send:messageModel socket:socket seq:tag callback:block];
    });
}
// ----------- tcp 打包，并发送, callback 回调 block ------------
- (void)send:(TOMMessageModel *)rootMsg  socket:(GCDAsyncSocket *) socket seq:(UInt32)s callback:(TCPBlock)block {
    
    // 包头是 32 位的整型，表示包体长度
    NSData *messageData = [rootMsg getSendData];
    SInt32 length = (SInt32)[messageData length];
    NSMutableData *data = [NSMutableData dataWithBytes:&length length:4];
    [data appendData:messageData];      // 追加包体
    //
//    if (block != nil) {
//        // 保存回调 block 到字典里，接收时候用到
//        NSString *key = [NSString stringWithFormat:@"%u", s];
//        [_dictionaryLock lock];
//        [_callbackBlock setObject:block forKey:key];
//        [_dictionaryLock unlock];
//        
//        // 30 秒超时, 找到 key 删除
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [self timerRemove:key];
//        });
//    }
    NSLog(@"通知 socket 发送数据");
    [[SocketServerManager instance] send:data socket:socket];   // 发送
}
#pragma mark  - SocketServerManagerDelegate

- (void)clientSocket:(GCDAsyncSocket *)socket didReadClientData:(NSData *)data
{
    [_buffer appendData:data];
    
    while (_buffer.length >= 4) {
        SInt32 length = 0;
        [_buffer getBytes:&length length:4];    // 读取长度
        
        if (length == 0) {
            if (_buffer.length >= 4) {          // 长度够不够心跳包
                NSData *tmp = [_buffer subdataWithRange:NSMakeRange(4, _buffer.length - 4)];
                [_buffer setLength:0];      // 清零
                [_buffer appendData:tmp];
            } else {
                [_buffer setLength:0];
            }
        } else {
            NSUInteger packageLength = 4 + length;
            if (packageLength <= _buffer.length) {     // 长度判断
                NSData *rootData = [_buffer subdataWithRange:NSMakeRange(4, length)];
                TOMMessageModel *root = [[TOMMessageModel alloc] initWithSocketData:rootData];
                // 截取
                NSData *tmp = [_buffer subdataWithRange:NSMakeRange(packageLength, _buffer.length - packageLength)];
                [_buffer setLength:0];      // 清零
                [_buffer appendData:tmp];
                NSLog(@"%@",root.dataDic);
                [self receive:root socket:socket];
            } else {
                break;
            }
        }
    }
}
//// 收到包进行分发
- (void)receive:(TOMMessageModel *)root socket:(GCDAsyncSocket *)sock {
    if (root == nil) {
        NSLog(@"收到心跳包");
        return ;
    }

    switch (root.type) {
        case TOMMessageTypeLogin:
        {
            TOMMessageModel *loginModel = [[TOMMessageModel alloc] initWithType:TOMMessageTypeLogin andMessageDic:@{@"loginStatus":@"1",@"userID":@"CodingTom"}];
            loginModel.tag = root.tag;
            [self send:loginModel socket:sock seq:root.tag callback:nil];
        }
            break;
            
        case TOMMessageTypeRunJS:
        {
            TOMMessageModel *runModel = [[TOMMessageModel alloc] initWithType:TOMMessageTypeLogin andMessageDic:@{@"Run":@"1",@"name":@"Liu与i"}];
            runModel.tag = root.tag;
            [self send:runModel socket:sock seq:root.tag callback:nil];
        }
            break;
        case TOMMessageTypePing:
        {
            [self send:root socket:sock seq:root.tag callback:nil];
        }
            break;

            
        default:
            NSLog(@"收到未知包 %ld", (long)root.type);
            break;
    }
}

@end
