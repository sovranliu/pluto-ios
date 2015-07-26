//
//  Future.m
//  Hello
//
//  Created by sovranliu on 15/7/25.
//  Copyright (c) 2015年 com.slfuture. All rights reserved.
//

#import "Future.h"

// 回调类
@implementation Future

@synthesize total = _total;
@synthesize progress = _progress;
@dynamic status;

// 初始化
- (id)init
{
    if (![super init]) return nil;
    self->_condition = [[NSCondition alloc] init];
    return self;
}


-(int) status
{
    return self->_status;
}

-(void) setStatus:(int) status
{
    bool sentry = NO;
    [self->_condition lock];
    if(FUTURE_STATUS_CONNECTING == self->_status || FUTURE_STATUS_UPLOADING == self->_status || FUTURE_STATUS_DOWNLOADING == self->_status)
    {
        if(FUTURE_STATUS_COMPLETED == status || FUTURE_STATUS_TIMEOUT == status || FUTURE_STATUS_INTERRUPTED == status || FUTURE_STATUS_ERROR == status)
        {
            sentry = YES;
        }
    }
    self->_status = status;
    if(sentry)
    {
        [self->_condition signal];
    }
    [self->_condition unlock];
}

// 放弃进度
-(void) discard
{
    self.status = FUTURE_STATUS_INTERRUPTED;
}

// 等待结束
-(void) await:(long) timeout
{
    [self->_condition lock];
    if(FUTURE_STATUS_COMPLETED == self->_status || FUTURE_STATUS_TIMEOUT == self->_status || FUTURE_STATUS_INTERRUPTED == self->_status || FUTURE_STATUS_ERROR == self->_status) {
        return;
    }
    [self->_condition wait];
    [self->_condition unlock];
}

// 下载
-(bool) download:(NSData *)data
{
    if(FUTURE_STATUS_TIMEOUT == self->_status || FUTURE_STATUS_INTERRUPTED == self->_status || FUTURE_STATUS_ERROR == self->_status)
    {
        return NO;
    }
    return YES;
}

// 回调结果
-(NSString *) result
{
    return nil;
}

@end


// 文本回调类
@implementation TextFuture

@synthesize text = _text;

// 初始化
- (id)init
{
    if (![super init]) return nil;
    self->_buffer = [[NSMutableData alloc] init];
    return self;
}

-(void) setStatus:(int) status
{
    if(FUTURE_STATUS_COMPLETED == status)
    {
        self.text = [[NSString alloc] initWithData:self->_buffer encoding:NSUTF8StringEncoding];
    }
    [super setStatus:status];
}

// 下载
-(bool) download:(NSData *)data
{
    bool result = [super download:data];
    if(result)
    {
        [self->_buffer appendData:data];
    }
    return result;
}

// 回调结果
-(NSString *) result
{
    return self.text;
}

@end


// 文本回调类
@implementation FileFuture

@synthesize path = _path;

// 初始化
- (id)init:(NSString *) path
{
    if (![super init]) return nil;
    self.path = path;
    self->_handle = nil;
    return self;
}

-(void) setStatus:(int) status
{
    if(FUTURE_STATUS_COMPLETED == status)
    {
        [self->_handle closeFile];
        self->_handle = nil;
    }
    [super setStatus:status];
}

// 下载
-(bool) download:(NSData *)data
{
    bool result = [super download:data];
    if(result)
    {
        if(nil != self->_handle) {
            [self->_handle closeFile];
            self->_handle = nil;
        }
        return NO;
    }
    if(![[NSFileManager defaultManager] fileExistsAtPath:self.path]) {
        [[NSFileManager defaultManager] createFileAtPath:self.path contents:nil attributes:nil];
    }
    if(nil == self->_handle) {
        self->_handle = [NSFileHandle fileHandleForWritingAtPath:self.path];
    }
    [self->_handle writeData:data];
    return YES;
}

@end
