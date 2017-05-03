//
//  CommandHandel.m
//  TomService
//
//  Created by Liuyujie on 2017/5/3.
//  Copyright © 2017年 CodingTom. All rights reserved.
//

#import "CommandHandel.h"
#import "FileUtil.h"

@implementation CommandHandel

static CommandHandel *commandHandel;

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        commandHandel = [[CommandHandel alloc] init];
    });
    return commandHandel;
}

- (void)handelCommandString:(NSString *)inputString
{
//    NSLog(@"输入的命令是：%@",inputString);
    [[FileUtil shareInstance] witeString:[NSString stringWithFormat:@"\n%@ : %@\n",[[NSDate date] description],inputString]];
    inputString = [inputString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSArray *commandArray = [inputString componentsSeparatedByString:@" "];
    if (commandArray.count == 2) {
        NSString *fileName = commandArray[1];
        if ([commandArray[0] isEqualToString:@"Run"] && [fileName hasSuffix:@".js"]) {
            [self sendRunCommand:fileName];
        }
    }
}

- (void)sendRunCommand:(NSString *)fileName
{
    NSString *jsContent = [[FileUtil shareInstance] readStringFromFile:fileName];
    if (jsContent) {
        NSLog(@"\n---JS Content---\n%@",jsContent);
        
    }
}

@end
