//
//  Game.h
//  Cetris
//
//  Created by Wan Wei on 14/7/23.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Client.h"

typedef enum : NSUInteger {
    GS_INIT, // connecting or authenticating
    GS_READY, // conntected,
    GS_GAMING, //
    GS_OVER,
} GameState;

@interface Game : NSObject<ClientDelegate>

-(void)start;

@end
