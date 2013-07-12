//
//  DBUtil.h
//  DropboxSync
//
//  Created by Stephen Poletto on 3/8/13.
//  Copyright (c) 2013 Dropbox, Inc. All rights reserved.
//

/** A set of various fields indicating the current status of syncing. */
enum DBSyncStatus {
	DBSyncStatusDownloading = (1 << 0),
	DBSyncStatusUploading = (1 << 1),
	DBSyncStatusSyncing = (1 << 2),
	DBSyncStatusActive = (1 << 3),
};

typedef NSUInteger DBSyncStatus;
