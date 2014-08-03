//
//  PlayerHud.m
//  Cetris
//
//  Created by Wan Wei on 14/7/24.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "PlayerHud.h"

@implementation PlayerHud {
    SKLabelNode *_nickNameLabel;
    SKLabelNode *_healthLabel;
    SKSpriteNode *_avatarNode;
    BOOL _isMe;
}

-(instancetype)initWithPlayer:(Player*)player IsMe:(BOOL) isMe {
    if(self = [super init]) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"sprite%lld", player.playerId]];
        _avatarNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:image] size:CGSizeMake(80, 80)];
        [self addChild:_avatarNode];

        _nickNameLabel = [SKLabelNode labelNodeWithFontNamed:@"System"];
        if (isMe) {
            _nickNameLabel.fontColor = [SKColor redColor];
        } else {
            _nickNameLabel.fontColor = [SKColor whiteColor];
        }
        
        _nickNameLabel.fontSize = 16.0f;
        _nickNameLabel.position = CGPointMake(_avatarNode.size.width + 20, 0);
        _nickNameLabel.text = player.nickName;
        [self addChild:_nickNameLabel];

        _healthLabel = [SKLabelNode labelNodeWithFontNamed:@"System"];
        _healthLabel.fontColor = [SKColor whiteColor];
        _healthLabel.fontSize = 16.0f;
        _healthLabel.text = [NSString stringWithFormat:@"%d", player.health];
        _healthLabel.position = CGPointMake(_nickNameLabel.position.x, _nickNameLabel.position.y - 30);
        [self addChild:_healthLabel];
    }
    return self;
}

-(void)setHealth:(int)Health {
    _healthLabel.text = [NSString stringWithFormat:@"%d", Health];
}

@end
