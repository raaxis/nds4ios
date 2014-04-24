//
//  DownloadManager.m
//  TestingPlatform
//
//  Created by Robert Ryan on 11/21/12.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "DownloadManager.h"
#import "Download.h"

@interface DownloadManager () <DownloadDelegate>

@property (nonatomic) BOOL cancelAllInProgress;

@end

@implementation DownloadManager

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _downloads = [[NSMutableArray alloc] init];
        _maxConcurrentDownloads = 12;
    }
    
    return self;
}

#pragma mark - DownloadManager public methods

- (void)addDownloadWithFilename:(NSString *)filename URL:(NSURL *)url
{
    Download *download = [[Download alloc] initWithFilename:filename URL:url delegate:self];
    
    [self.downloads addObject:download];
}

- (void)start
{
    [self tryDownloading];
}

- (void)cancelAll
{
    self.cancelAllInProgress = YES;
    
    while ([self.downloads count] > 0)
    {
        [[self.downloads objectAtIndex:0] cancel];
    }
    
    self.cancelAllInProgress = NO;
    
    [self informDelegateThatDownloadsAreDone];
}

- (id)initWithDelegate:(id<DownloadManagerDelegate>)delegate
{
    self = [self init];
    
    if (self)
    {
        _delegate = delegate;
    }
    
    return self;
}

#pragma mark - DownloadDelegate Methods

- (void)downloadDidFinishLoading:(Download *)download
{
    [self.downloads removeObject:download];
    
    if ([self.delegate respondsToSelector:@selector(downloadManager:downloadDidFinishLoading:)])
    {
        [self.delegate downloadManager:self downloadDidFinishLoading:download];
    }

    [self tryDownloading];
}

- (void)downloadDidFail:(Download *)download
{
    [self.downloads removeObject:download];

    if ([self.delegate respondsToSelector:@selector(downloadManager:downloadDidFail:)])
        [self.delegate downloadManager:self downloadDidFail:download];

    if (!self.cancelAllInProgress)
    {
        [self tryDownloading];
    }
}

- (void)downloadDidReceiveData:(Download *)download
{
    if ([self.delegate respondsToSelector:@selector(downloadManager:downloadDidReceiveData:)])
    {
        [self.delegate downloadManager:self downloadDidReceiveData:download];
    }
}

#pragma mark - Private methods

- (void)informDelegateThatDownloadsAreDone
{
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingAllForManager:)])
    {
        [self.delegate didFinishLoadingAllForManager:self];
    }
}

- (void)tryDownloading
{
    NSInteger totalDownloads = [self.downloads count];
    
    // if we're done, inform the delegate
    
    if (totalDownloads == 0)
    {
        [self informDelegateThatDownloadsAreDone];
        return;
    }
    
    // while there are downloads waiting to be started and we haven't hit the maxConcurrentDownloads, then start
    
    while ([self countUnstartedDownloads] > 0 && [self countActiveDownloads] < self.maxConcurrentDownloads)
    {
        for (Download *download in self.downloads)
        {
            if (!download.isDownloading)
            {
                [download start];
                break;
            }
        }
    }
}

- (NSInteger)countUnstartedDownloads
{
    return [self.downloads count] - [self countActiveDownloads];
}

- (NSInteger)countActiveDownloads
{
    NSInteger activeDownloadCount = 0;
    
    for (Download *download in self.downloads)
    {
        if (download.isDownloading)
            activeDownloadCount++;
    }
    
    return activeDownloadCount;
}

@end
