//
//  SocketServerManager.h
//  TomService
//
//  Created by CodingTom on 2017/4/25.
//  Copyright © 2017年 CodingTom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@protocol SocketServerManagerDelegate <NSObject>

- (void)clientSocket:(GCDAsyncSocket *)socket didReadClientData:(NSData *)data;

@end

@interface SocketServerManager : NSObject

+ (SocketServerManager *)instance;    // 可以使用单例，也可以 alloc 一个新的临时用

@property (weak, nonatomic) id<SocketServerManagerDelegate> delegate;


@end
