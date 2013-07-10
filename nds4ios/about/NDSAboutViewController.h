//
//  NDSAboutViewController.h
//  nds4ios
//
//  Created by Developer on 7/8/13.
//  Copyright (c) 2013 DS Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NDSAboutViewController : UITableViewController {
    BOOL _canTweet;
    IBOutlet UIBarButtonItem *tweetButton;
}
- (IBAction)sendTweet:(id)sender;

@end
