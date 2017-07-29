//
//  ViewController.m
//  TestSwizzling
//
//  Created by Alban Diquet on 7/28/17.
//  Copyright © 2017 Alban Diquet. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                                                          delegate:self
                                                     delegateQueue:nil];
    
    // Use NSURLSession
    // Load a URL with a bad pinning configuration to demonstrate a pinning failure with a report being sent
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:@"https://www.yahoo.com/"]];
    [task resume];
    
    // Load a URL with a good pinning configuration
    NSURLSessionDataTask *task2 = [session dataTaskWithURL:[NSURL URLWithString:@"https://www.datatheorem.com/"]];
    [task2 resume];
    
    // Also use NSURLConnection
    NSURLConnection *connection = [[NSURLConnection alloc]
                                   initWithRequest:[NSURLRequest requestWithURL:
                                                    [NSURL URLWithString:@"https://www.yahoo.com/"]]
                                   delegate:self];
    [connection start];
    
    NSURLConnection *connection2 = [[NSURLConnection alloc]
                                    initWithRequest:[NSURLRequest requestWithURL:
                                                    [NSURL URLWithString:@"https://www.datatheorem.com/"]]
                                   delegate:self];
    [connection2 start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)URLSession:(NSURLSession * _Nonnull)session
              task:(NSURLSessionTask * _Nonnull)task
didCompleteWithError:(NSError * _Nullable)error
{
    if (error)
    {
        // An error will only be triggered when loading
        NSLog(@"Received error (NSURLSession) %@", error);
    }
}


- (void)URLSession:(NSURLSession * _Nonnull)session
          dataTask:(NSURLSessionDataTask * _Nonnull)dataTask
    didReceiveData:(NSData * _Nonnull)data
{
    NSLog(@"Received content (NSURLSession)");
}


- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    if (error)
    {
        // An error will only be triggered when loading
        NSLog(@"Received error (NSURLConnection) %@", error);
    }
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Received content (NSURLConnection)");
}


@end
