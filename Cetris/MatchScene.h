//
//  MatchScene.h
//  Cetris
//
//  Created by Wan Wei on 14/7/26.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Client.h"
#import "Game.h"
#import "Car.h"

@interface MatchScene : SKScene <SKPhysicsContactDelegate, ClientDelegate, CarDelegate>

-(instancetype)initWithSize:(CGSize)size Game:(Game*)game;

@end
