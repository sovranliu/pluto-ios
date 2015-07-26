//
//  Future.h
//
//  Created by sovranliu on 25/7/15.
//  Copyright (c) 2015年 com.slfuture. All rights reserved.
//

#import <Foundation/Foundation.h>

// 状态：就绪
#define FUTURE_STATUS_READY 0
// 状态：连接进行
#define FUTURE_STATUS_CONNECTING 1
// 状态：上传进行
#define FUTURE_STATUS_UPLOADING 2
// 状态：下载进行
#define FUTURE_STATUS_DOWNLOADING 3
// 状态：完成终止
#define FUTURE_STATUS_COMPLETED 4
// 状态：超时终止
#define FUTURE_STATUS_TIMEOUT 5
// 状态：中断终止
#define FUTURE_STATUS_INTERRUPTED 6
// 状态：错误终止
#define FUTURE_STATUS_ERROR 7


// 回调类
@interface Future : NSObject
{
@private
    // 状态
    int _status;
    // 条件锁
    NSCondition* _condition;
}

// 总量
@property (atomic) unsigned long total;
// 进度
@property (atomic) unsigned long progress;
// 状态
@property (atomic) int status;

// 初始化
- (id)init;
// 放弃进度
-(void) discard;
// 等待结束
-(void) await:(long) timeout;
// 下载
-(bool) download:(NSData *)data;
// 回调结果
-(NSString *) result;

@end


// 文本回调类
@interface TextFuture : Future
{
@private
    NSMutableData* _buffer;
}

// 下载的文本
@property (strong, atomic) NSString* text;

@end


// 文件回调类
@interface FileFuture : Future
{
@private
    NSFileHandle* _handle;
}

// 下载文件路径
@property (strong, atomic) NSString* path;

@end

