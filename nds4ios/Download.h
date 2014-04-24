//
//  Download.h
//  TestingPlatform
//
//  Created by Robert Ryan on 11/13/12.
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

@class Download;

/** The `Download` class defines a delegate protocol, `DownloadDelegate`,
 * to inform the `delegate` regarding the success or failure of a download.
 *
 * @see Download
 */

@protocol DownloadDelegate <NSObject>

@optional

/** Called to notify delegate that the download completed.
 *
 * @param download
 *
 * Pointer to the `Download` that just completed.
 *
 * @see Download
 *
 */

- (void)downloadDidFinishLoading:(Download *)download;

/** Called to notify delegate that the download completed.
 *
 * @param download
 *
 * Pointer to the `Download` that just failed.
 *
 * @see Download
 *
 */

- (void)downloadDidFail:(Download *)download;

/** Called to notify delegate that the download completed.
 *
 * @param download
 *
 * Pointer to the `Download` that just failed.
 *
 * @see Download
 *
 */

- (void)downloadDidReceiveData:(Download *)download;

@end

/** The `Download` is a class to download a single file using `NSURLConnection`. 
 * Generally you will not interact directly with this class, but rather just
 * employ the `DownloadManager` class.
 *
 * @see DownloadManager
 */

@interface Download : NSObject <NSURLConnectionDelegate>

/// @name Properties

/** The local filename of the file being downloaded. Generally not set manually, but rather by call to `initWithFilename:URL:delegate:`.
 *
 * @see initWithFilename:URL:delegate:
 */

@property (nonatomic, copy) NSString *filename;

/** The remote URL of the file being downloaded. Generally not set manually, but rather by call to `initWithFilename:URL:delegate:`.
 *
 * @see initWithFilename:URL:delegate:
 */

@property (nonatomic, copy) NSURL *url;

/** The delegate object that conforms to `DownloadDelegate`, if any.
 *
 * @see DownloadDelegate
 */

@property (nonatomic, weak) id<DownloadDelegate> delegate;

/// `BOOL` property designating whether this download is in progress or not.

@property (getter = isDownloading) BOOL downloading;

/** `long long` property that designates how large the file is (in bytes). Some
 * servers will provide this information, some will not. If no size
 * information provided, `expectedContentLength` will be negative.
 *
 * @warning Even if servers provide this information, this is not
 * always reliable. Never depend upon the accuracy of this property.
 */

@property long long expectedContentLength;

/// `long long` property indicates the current progress (in bytes).

@property long long progressContentLength;

/// If there was an error, what was it. Otherwise `nil`.

@property (nonatomic, strong) NSError *error;

/// @name Initialization

/** Returns pointer to `Download` object and initiates download from `url`, saving the file to `filename`.
 *
 * @param filename
 *
 * The local filename of the file being downloaded.
 *
 * @param url
 *
 * The remote URL of the file being downloaded. 
 *
 * @param delegate
 *
 * The delegate object to be notified of the status of the download. Must conform to `DownloadDelegate` protocol. This is optional.
 *
 */

- (id)initWithFilename:(NSString *)filename URL:(NSURL *)url delegate:(id<DownloadDelegate>)delegate;

/// @name Control

/// Start the individual download.

- (void)start;

/// Cancel the individual download, whether in progress or simply pending.

- (void)cancel;

@end
