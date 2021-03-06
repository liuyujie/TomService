//
//  TCPServer.h
//  TomService
//
//  Created by CodingTom on 2017/4/25.
//  Copyright © 2017年 CodingTom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TOMMessageModel.h"
#import "TCPClient.h"
#import "GCDAsyncSocket.h"

@interface TCPServer : NSObject

+ (TCPServer *)instance;

@property (strong,nonatomic)NSMutableArray *socketArray;

- (void)sendRunJSCommand:(NSString *)message completion:(TCPBlock)block;

- (void)sendTomMessage:(TOMMessageModel *)messageModel Socket:(GCDAsyncSocket *)socket completion:(TCPBlock)block;

@end
