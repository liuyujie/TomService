//
//  FileUtil.m
//  BugReportService
//
//  Created by Liuyujie on 2017/4/24.
//  Copyright © 2017年 Chemi Technologies(Beijing)Co.,ltd. All rights reserved.
//

#import "FileUtil.h"
#include <mach-o/dyld.h>

@interface FileUtil()
{
    
}

@property (nonatomic,strong)NSFileHandle *logFileHandle;
@property (nonatomic,strong)NSString *appPWDPath;

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

- (NSString *)getAppPath
{
    if (!_appPWDPath) {
        char buf[0];
        uint32_t size = 0;
        _NSGetExecutablePath(buf,&size);
        char* path = (char*)malloc(size+1);
        path[size] = 0;
        _NSGetExecutablePath(path,&size);
        char* pCur = strrchr(path, '/');
        *pCur = 0;
        _appPWDPath = [NSString stringWithUTF8String:path];
        free(path);
        path = NULL;
    }
    return _appPWDPath;
}

- (NSString *)readStringFromFile:(NSString *)fileName
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[self getAppPath],fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
       return [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    }else{
        NSLog(@"\n此目录【%@】未找到对应的文件，请创建后重试！\n",filePath);
    }
    return nil;
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
