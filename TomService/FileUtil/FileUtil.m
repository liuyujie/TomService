//
//  FileUtil.m
//  BugReportService
//
//  Created by Liuyujie on 2017/4/24.
//  Copyright © 2017年 Chemi Technologies(Beijing)Co.,ltd. All rights reserved.
//

#import "FileUtil.h"

@interface FileUtil()
{
    
}

@property (nonatomic,strong)NSFileHandle *logFileHandle;

@end

@implementation FileUtil

static FileUtil *fileUtil;

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fileUtil = [[FileUtil alloc] init];
    });
    return fileUtil;
}

- (BOOL)witeString:(NSString *)string
{
    [self.logFileHandle writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    
    return YES;
}

- (NSFileHandle *)logFileHandle
{
    if (!_logFileHandle) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *filePath = @"/Users/LiuYujie/Desktop/ZXSH/congTom.log";
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        _logFileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    }
    return _logFileHandle;
}

@end
