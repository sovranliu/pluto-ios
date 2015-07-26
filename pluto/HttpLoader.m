//
//  HttpLoader.m
//
//  Created by sovranliu on 15/7/26.
//  Copyright (c) 2015年 com.slfuture. All rights reserved.
//

#import "HttpLoader.h"

// HTTP异步任务
@implementation HttpTask

@synthesize url = _url;
@synthesize parameters = _parameters;
@synthesize option = _option;
@synthesize future = _future;

-(void) main
{
    [HttpUtil send:self.url withParameters:self.parameters withOption:self.option withFuture:self.future];
}

@end


// HTTP下载器
@implementation HttpLoader

// 初始化
-(bool) initialize:(int)operatorMaxCount
{
    self->_queue = [[NSOperationQueue alloc] init];
    [self->_queue setMaxConcurrentOperationCount:1];
    return YES;
}

// 析构
-(void) terminate
{
    [self->_queue cancelAllOperations];
    self->_queue = nil;
}

// 发送
-(NSString *) send:(NSString *) url withParameters:(NSDictionary *) parameters withOption:(Option *) option withFuture:(Future *) future
{
    HttpTask* task = [[HttpTask alloc] init];
    task.url = url;
    task.parameters = parameters;
    task.option = option;
    task.future = future;
    [self->_queue addOperation:task];
    return nil;
}

@end
