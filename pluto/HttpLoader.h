//
//  HttpLoader.h
//
//  Created by sovranliu on 15/7/26.
//  Copyright (c) 2015年 com.slfuture. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Future.h"
#import "HttpUtil.h"

// HTTP异步任务
@interface HttpTask : NSOperation

@property (strong) NSString* url;
@property (strong) NSDictionary* parameters;
@property (strong) Option* option;
@property (strong) Future* future;

@end


// HTTP下载器
@interface HttpLoader : NSObject
{
@private
    NSOperationQueue* _queue;
}

// 初始化
-(bool) initialize:(int)operatorMaxCount;
// 析构
-(void) terminate;

// 发送
-(NSString *) send:(NSString *) url withParameters:(NSDictionary *) parameters withOption:(Option *) option withFuture:(Future *) future;

@end
