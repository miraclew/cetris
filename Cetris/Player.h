//
//  Player.h
//  Cetris
//
//  Created by Wan Wei on 14/7/25.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Player : NSObject

@property int64_t playerId;
@property NSString* nickName;
@property NSString* avatar;
@property BOOL isLeft;
@property CGPoint position;
@property int health;

@end
