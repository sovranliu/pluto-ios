//
//  HttpUtil.h
//
//  Created by sovranliu on 15/7/26.
//  Copyright (c) 2015年 com.slfuture. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Future.h"


// 选项类
@interface Option : NSObject

@property (nonatomic) int timeout;

@end


// 同步连接类
@interface SyncURLConnection : NSObject<NSURLConnectionDataDelegate>
{
@private
    // 条件锁
    NSCondition* _condition;
}

@property (strong) NSURLConnection* connection;
@property (strong) Future* future;

-(NSString *) send:(NSString *) url withParameters:(NSDictionary *) parameters withOption:(Option *) option withFuture:(Future *) future;

@end


// HTTP工具类
@interface HttpUtil : NSObject

// 访问
+(NSString *) send:(NSString *) url withParameters:(NSDictionary *) parameters withOption:(Option *) option withFuture:(Future *) future;

@end
