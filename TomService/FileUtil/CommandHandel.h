//
//  CommandHandel.h
//  TomService
//
//  Created by Liuyujie on 2017/5/3.
//  Copyright © 2017年 CodingTom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommandHandel : NSObject

+ (instancetype)shareInstance;

- (void)handelCommandString:(NSString *)inputString;

@end
