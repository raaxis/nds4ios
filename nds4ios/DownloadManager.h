//
//  DownloadManager.h
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

#import <Foundation/Foundation.h>
#import "Download.h"

@class DownloadManager;
@class Download;

/** This delegate protocol informs the `delegate` regarding the success or failure of the downloads.
 *
 * @see DownloadManager
 * @see Download
 * @see delegate
 */

@protocol DownloadManagerDelegate <NSObject>

@optional

/** Informs the delegate that all downloads have finished (whether successfully or unsuccessfully).
 *
 * @param downloadManager
 *
 * The `DownloadManager` that is performing the downloads.
 *
 * @see DownloadManager
 */

- (void)didFinishLoadingAllForManager:(DownloadManager *)downloadManager;

/** Informs the delegate that a particular download has finished successfully.
 *
 * @param downloadManager
 *
 * The `DownloadManager` that is performing the downloads.
 *
 * @param download
 *
 * The individual `Download`.
 *
 * @see DownloadManager
 * @see Download
 */

- (void)downloadManager:(DownloadManager *)downloadManager downloadDidFinishLoading:(Download *)download;

/** Informs the delegate that a particular download has failed.
 *
 * @param downloadManager
 *
 * The `DownloadManager` that is performing the downloads.
 *
 * @param download
 *
 * The individual `Download`.
 *
 * @see DownloadManager
 * @see Download
 */

- (void)downloadManager:(DownloadManager *)downloadManager downloadDidFail:(Download *)download;

/** Informs the delegate of the status of a particular download that is in progress.
 *
 * @param downloadManager
 *
 * The `DownloadManager` that is performing the downloads.
 *
 * @param download
 *
 * The individual `Download`.
 *
 * @see DownloadManager
 * @see Download
 */

- (void)downloadManager:(DownloadManager *)downloadManager downloadDidReceiveData:(Download *)download;

@end

/** While the `Download` class downloads individual files, `DownloadManager` allows 
 * you to coordinate multiple downloads. If you use this `DownloadManager` class, 
 * you do not have to interact directly with the `Download` class (other than 
 * optionally inquiring about the progress of the downloads in the `DownloadManagerDelegate` 
 * methods).
 *
 * @see DownloadManagerDelegate
 * @see Download
 */

@interface DownloadManager : NSObject

/// @name Initialization

/** Returns pointer to initialized `DownloadManager` object.
 *
 * @param delegate
 *
 * The delegate that conforms to `DownloadManagerDelegate` which will receive 
 * information regarding the progress of the downloads.
 *
 * @return
 *
 * Returns pointer to `DownloadManager` object. If error, this is `nil`.
 *
 * @see DownloadManagerDelegate
 */

- (id)initWithDelegate:(id<DownloadManagerDelegate>)delegate;

/// @name Control Download Manager

/** Add a download to the manager.
 *
 * @param filename
 *
 * The name of the local filename to where the file should be copied.
 *
 * @param url
 *
 * The remote URL of the source from where the file should be copied.
 *
 * @see filename
 * @see url
 */

- (void)addDownloadWithFilename:(NSString *)filename URL:(NSURL *)url;

/// Starts the queued downloads.

- (void)start;

/// Cancel all downloads in progress or pending.

- (void)cancelAll;

/// @name Properties

/** The maximum number of permissible number of concurrent downloads.
 * Many servers limit the number of concurrent downloads (4 or 6 are common)
 * and failure to observe this threshold will result in failures. Good
 * common practice is to set this to be 4.
 */

@property NSInteger maxConcurrentDownloads;

/** The array of `Download` objects representing the list of the ongoing or pending downloads.
 *
 * @see Download
 */

@property (nonatomic, strong) NSMutableArray *downloads;

/** The delegate object that this class notifies regarding the progress of the individual downloads.
 *
 * @see DownloadManagerDelegate
 */

@property (nonatomic, weak) id<DownloadManagerDelegate> delegate;

@end
