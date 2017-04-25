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

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        [TCPServer instance];
        BOOL stop = NO;
        while (!stop) {
            char buffer[200];     //使用一个缓冲区
            NSLog(@"请输入命令：");
            fgets(buffer, 200, stdin);
            NSString *str = [NSString stringWithUTF8String:buffer];    //将缓冲区赋给NSString变量
            if ([str isEqualToString:@"exit;\n"]) {
                stop = YES;
            }
            NSLog(@"输入的命令是：%@",str);
            [[FileUtil shareInstance] witeString:str];
        }
    }
    return 0;
}
