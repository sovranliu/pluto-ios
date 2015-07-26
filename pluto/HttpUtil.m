//
//  HttpUtil.m
//
//  Created by sovranliu on 15/7/26.
//  Copyright (c) 2015年 com.slfuture. All rights reserved.
//

#import "HttpUtil.h"

// 选项类
@implementation Option

@synthesize timeout = _timeout;

@end


// 同步连接类
@implementation SyncURLConnection

@synthesize connection = _connection;
@synthesize future = _future;


-(NSString *) send:(NSString *) url withParameters:(NSDictionary *) parameters withOption:(Option *) option withFuture:(Future *) future
{
    int timeout = 0;
    if(nil != option)
    {
        timeout = option.timeout;
    }
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeout];
    [request setHTTPMethod:@"GET"];
    [request addValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    if(nil == future) {
        self.future = [[Future alloc] init];
    }
    else {
        self.future = future;
    }
    //
    self->_condition = [[NSCondition alloc] init];
    [self->_condition lock];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self->_condition wait];
    [self->_condition unlock];
    return [future result];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"NSURLConnection.didReceiveResponse() execute");
    self.future.status = FUTURE_STATUS_DOWNLOADING;
    self.future.total = [response expectedContentLength];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"NSURLConnection.didReceiveData() execute");
    [self.future download:data];
    self.future.progress += data.length;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"NSURLConnection.connectionDidFinishLoading() execute");
    self.future.status = FUTURE_STATUS_COMPLETED;
    //
    [self->_condition lock];
    [self->_condition signal];
    [self->_condition unlock];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"NSURLConnection.didFailWithError() execute");
    self.future.status = FUTURE_STATUS_ERROR;
    //
    [self->_condition lock];
    [self->_condition signal];
    [self->_condition unlock];
}

@end


// HTTP工具类
@implementation HttpUtil

// 访问
+(NSString *) send:(NSString *) url withParameters:(NSDictionary *) parameters withOption:(Option *) option withFuture:(Future *) future
{
    SyncURLConnection* urlConnection = [[SyncURLConnection alloc] init];
    [urlConnection send:url withParameters:parameters withOption:option withFuture:future];
    return urlConnection.future.result;
}

@end
