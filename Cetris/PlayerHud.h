//
//  PlayerHud.h
//  Cetris
//
//  Created by Wan Wei on 14/7/24.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayerHud : SKSpriteNode

@property (nonatomic, assign) NSInteger playerId;
@property (nonatomic, strong) NSString* nickName;
@property (nonatomic, strong) NSString* avatar;
@property (nonatomic, strong) NSString* health;

@end
