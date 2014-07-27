//
//  StartScene.h
//  Cetris
//
//  Created by Wan Wei on 14/7/27.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Game.h"

@interface StartScene : SKScene

-(id)initWithSize:(CGSize)size  Game:(Game*)game;
-(void)ready;

@end
