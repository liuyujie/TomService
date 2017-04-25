//
//  SocketServerManager.m
//  TomService
//
//  Created by CodingTom on 2017/4/25.
//  Copyright © 2017年 CodingTom. All rights reserved.
//

#import "SocketServerManager.h"

@interface SocketServerManager()
{
}

@property (strong, nonatomic) GCDAsyncSocket *socket;
@property (strong, nonatomic) dispatch_queue_t socketQueue;         // 发数据的串行队列
@property (strong, nonatomic) dispatch_queue_t receiveQueue;        // 收数据处理的串行队列
@property (assign, nonatomic) UInt16 port;
@property (strong, nonatomic) NSMutableSet *clientSocketSet;

@end

@implementation SocketServerManager

static SocketServerManager *instance = nil;
static NSTimeInterval TimeOut = -1;

+ (SocketServerManager *)instance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SocketServerManager alloc] init];
    });
    return instance;
}

- (dispatch_queue_t)socketQueue {
    if (_socketQueue == nil) {
        _socketQueue = dispatch_queue_create("tom.server.sendSocket", DISPATCH_QUEUE_SERIAL);
    }
    return _socketQueue;
}

- (dispatch_queue_t)receiveQueue {
    if (_receiveQueue == nil) {
        _receiveQueue = dispatch_queue_create("tom.server.receiveSocket", DISPATCH_QUEUE_SERIAL);
    }
    return _receiveQueue;
}

- (NSMutableSet *)clientSocketSet {
    if (!_clientSocketSet) {
        _clientSocketSet = [NSMutableSet set];
    }
    return _clientSocketSet;
}

- (void)startServerWithPort:(UInt16)port
{
    self.port = port;
    self.socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:self.socketQueue];
    NSError *error = nil;
    [self.socket acceptOnPort:self.port error:&error];
    if (error) {
        NSLog(@"服务开启失败");
    } else {
        NSLog(@"服务开启成功");
    }
}
- (void)send:(NSData *)data socket:(GCDAsyncSocket *)socket {
    NSLog(@"socket send 发送数据");
    // socket 的操作要在 self.socketQueue（socket 的代理队列）中才有效，不允许其他线程来设置本 socket
    dispatch_async(self.socketQueue, ^{
        if (socket && !socket.isDisconnected) {
            [socket writeData:data withTimeout:TimeOut tag:100];
        }
    });
}

#pragma mark - GCDAsyncSocketDelegate
/*!
 @method  收到socket端连接回调
 @abstract 服务器收到socket端连接回调
 */
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    [self.clientSocketSet addObject:newSocket];
    [newSocket readDataWithTimeout:TimeOut tag:self.clientSocketSet.count];
}

/*!
 @method  收到socket端数据的回调
 @abstract 服务器收到socket端数据的回调
 */
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    // 直接进行转发数据
    for (GCDAsyncSocket *clientSocket in self.clientSocketSet) {
        if (sock == clientSocket) {
            dispatch_async(self.receiveQueue, ^{
                // 防止 didReadData 被阻塞，用个其他队列里的线程去回调 block
                if (self.delegate && [self.delegate respondsToSelector:@selector(clientSocket:didReadClientData:)]) {
                    [self.delegate clientSocket:sock didReadClientData:data];
                }
            });
        }
    }
    [sock readDataWithTimeout:TimeOut tag:100];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    [self.clientSocketSet removeObject:sock];
}

@end
