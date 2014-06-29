//
//  Terrain.m
//  Cetris
//
//  Created by Wan Wei on 14/6/28.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "Terrain.h"

#define kMaxHillKeyPoints 16
#define kHillSegmentWidth 5
#define kMaxHillVertices 4000
#define kMaxBorderVertices 800

@interface Terrain() {
    CGPoint _hillKeyPoints[kMaxHillKeyPoints];
    
}

@property CGSize size;
@end

@implementation Terrain

-(id) initWithSize:(CGSize) size {
    if (self = [super init]) {
        _size = size;
        [self generateHills];
        [self generateTerrian];
    }
    return self;
}

-(void)generateTerrian{
    CGMutablePathRef pathToDraw = CGPathCreateMutable();
    CGPathMoveToPoint(pathToDraw, NULL, 0.0, 0.0);
    for (int i=0; i<kMaxHillKeyPoints - 1; i++) {
        CGPoint p0 = _hillKeyPoints[i];
        CGPoint p1 = _hillKeyPoints[i+1];
        int hSegments = floorf((p1.x-p0.x)/kHillSegmentWidth);
        float dx = (p1.x - p0.x) / hSegments;
        float da = M_PI / hSegments;
        float ymid = (p0.y + p1.y) / 2;
        float ampl = (p0.y - p1.y) / 2;
        
        CGPoint pt0, pt1;
        pt0 = p0;
        for (int j = 0; j < hSegments+1; ++j) {
            
            pt1.x = p0.x + j*dx;
            pt1.y = ymid + ampl * cosf(da*j);
            
            CGPathAddLineToPoint(pathToDraw, NULL, pt0.x, pt0.y);
            CGPathAddLineToPoint(pathToDraw, NULL, pt1.x, pt1.y);
            pt0 = pt1;
        }
        
    }
    
    self.path = pathToDraw;
    [self setStrokeColor:[UIColor redColor]];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:pathToDraw];
    self.physicsBody.friction = 1.0f;
}

- (void) generateHills {
    
    float minDX = 60; // x 最小间隔
    float minDY = 10;
    int rangeDX = 40;
    int rangeDY = 60;
    
    float x = -minDX;
    float y = _size.height/2;
    
    float dy, ny;
    float sign = 1; // +1 - going up, -1 - going  down
    float paddingTop = 20;
    float paddingBottom = 20;
    
    for (int i=0; i<kMaxHillKeyPoints; i++) {
        _hillKeyPoints[i] = CGPointMake(x, y);
        if (i == 0) {
            x = 0;
            y = _size.height/2;
        } else {
            x += rand()%rangeDX+minDX;
            while(true) {
                dy = rand()%rangeDY+minDY;
                ny = y + dy*sign;
                if(ny < _size.height-paddingTop && ny > paddingBottom) {
                    break;
                }
            }
            y = ny;
        }
        sign *= -1;
    }
}

@end
