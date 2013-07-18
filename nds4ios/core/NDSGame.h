//
//  NDSGame.h
//  nds4ios
//
//  Created by Zydeco on 16/7/2013.
//  Copyright (c) 2013 DS Team. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const NDSGameSaveStatesChangedNotification;

@interface NDSGame : NSObject

@property (strong, nonatomic) NSString *path;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *gameTitle;
@property (nonatomic, readonly) UIImage *icon;
@property (nonatomic, readonly) NSInteger numberOfSaveStates;
@property (strong, nonatomic) NSString *pathForSavedStates;
@property (nonatomic, readonly) BOOL hasPauseState;

+ (NSArray*)gamesAtPath:(NSString*)path saveStateDirectoryPath:(NSString*)saveStatePath;
+ (NDSGame*)gameWithPath:(NSString*)path saveStateDirectoryPath:(NSString*)saveStatePath;
- (NDSGame*)initWithPath:(NSString*)path saveStateDirectoryPath:(NSString*)saveStatePath;
- (NSString*)pathForSaveStateWithName:(NSString*)name;
- (NSString*)pathForSaveStateAtIndex:(NSInteger)idx;
- (NSString*)nameOfSaveStateAtIndex:(NSInteger)idx;
- (NSDate*)dateOfSaveStateAtIndex:(NSInteger)idx;
- (BOOL)deleteSaveStateAtIndex:(NSInteger)idx;
- (void)reloadSaveStates;

@end
