//
//  FileUtil.h
//  BugReportService
//
//  Created by Liuyujie on 2017/4/24.
//  Copyright © 2017年 Chemi Technologies(Beijing)Co.,ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtil : NSObject

+ (instancetype)shareInstance;

- (BOOL)witeString:(NSString *)string;


@end
