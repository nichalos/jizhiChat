//
//  RCHttpRequest.m
//  RongIM
//
//  Created by Heq.Shinoda on 14-6-9.
//  Copyright (c) 2014年 Heq.Shinoda. All rights reserved.
//

#import "RCHttpRequest.h"


static RCHttpRequest *pDefaultRequest = nil;

@implementation RCHttpRequest

+(RCHttpRequest*)defaultHttpRequest
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(pDefaultRequest == nil)
        {
            pDefaultRequest = [[RCHttpRequest alloc] init];
        }
    });
    return pDefaultRequest;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}
//----Http comunication----//
-(void)httpConnectionWithURL:(NSString*)strURL bodyData:(NSData*)data delegate:(id<HttpConnectionDelegate>)delegate
{
    DebugLog(@"http url ==> %@",strURL);
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:strURL]
																cachePolicy:NSURLRequestReturnCacheDataElseLoad
															timeoutInterval:12.0];
	[request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    self.httpDelegate = delegate;
	self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	//if(connection != self.connection) return;
	self.response = (NSHTTPURLResponse*)response;
    self.responseData = [[NSMutableData alloc] initWithCapacity:0];

    DebugLog(@"response.statusCode ==> %d",self.response.statusCode);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	//if(connection != self.connection) return;
    
	if([self.httpDelegate respondsToSelector:@selector(responseHttpConnectionSuccess:)]) {
		[self.httpDelegate responseHttpConnectionSuccess:self];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    DebugLog(@"request  didFailWithError %@",error);
	//if(connection != self.connection) return;
    
	if([self.httpDelegate respondsToSelector:@selector(responseHttpConnectionFailed:didFailWithError:)])
    {
		[self.httpDelegate responseHttpConnectionFailed:self didFailWithError:error];
	}
}
@end
