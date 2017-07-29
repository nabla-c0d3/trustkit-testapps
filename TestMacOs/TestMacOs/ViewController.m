//
//  ViewController.m
//  TestMacOs
//
//  Created by Alban Diquet on 7/28/17.
//  Copyright © 2017 Alban Diquet. All rights reserved.
//

#import "ViewController.h"
#import <TrustKit/TrustKit.h>


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Initialize TrustKit
    NSDictionary *trustKitConfig =
    @{
      kTSKSwizzleNetworkDelegates: @YES,
      kTSKIgnorePinningForUserDefinedTrustAnchors: @YES,
      
      kTSKPinnedDomains: @{
              
              // Pin invalid SPKI hashes to *.yahoo.com to demonstrate pinning failures
              @"yahoo.com": @{
                      kTSKEnforcePinning: @YES,
                      kTSKIncludeSubdomains: @YES,
                      kTSKPublicKeyAlgorithms: @[kTSKAlgorithmRsa2048],
                      
                      // Wrong SPKI hashes to demonstrate pinning failure
                      kTSKPublicKeyHashes: @[
                              @"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
                              @"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="
                              ],
                      
                      // Send reports for pinning failures
                      // Email info@datatheorem.com if you need a free dashboard to see your App's reports
                      kTSKReportUris: @[@"https://overmind.datatheorem.com/trustkit/report"]
                      },
              
              
              // Pin valid SPKI hashes to www.datatheorem.com to demonstrate success
              @"www.datatheorem.com" : @{
                      kTSKEnforcePinning:@YES,
                      kTSKPublicKeyAlgorithms : @[kTSKAlgorithmEcDsaSecp384r1],
                      
                      // Valid SPKI hashes to demonstrate success
                      kTSKPublicKeyHashes : @[
                              @"58qRu/uxh4gFezqAcERupSkRYBlBAvfcw7mEjGPLnNU=", // CA key: COMODO ECC Certification Authority
                              @"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=", // Fake key but 2 pins need to be provided
                              ]
                      }}};
    
    [TrustKit initSharedInstanceWithConfiguration:trustKitConfig];
    
    
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
