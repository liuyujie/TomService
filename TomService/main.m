//
//  main.m
//  BugReportService
//
//  Created by Liuyujie on 2017/4/24.
//  Copyright © 2017年 Chemi Technologies(Beijing)Co.,ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileUtil.h"
#import "TCPServer.h"
#import "CommandHandel.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"当前程序的目录是：%@",[[FileUtil shareInstance] getAppPath]);
        [TCPServer instance];
        BOOL stop = NO;
        while (!stop) {
            char buffer[200];     //使用一个缓冲区
            NSLog(@"请输入命令：");
            fgets(buffer, 200, stdin);
            NSString *inputString = [NSString stringWithUTF8String:buffer];    //将缓冲区赋给NSString变量
            if ([inputString isEqualToString:@"exit;\n"]) {
                stop = YES;
            }
            [[CommandHandel shareInstance] handelCommandString:inputString];
        }
    }
    return 0;
}

