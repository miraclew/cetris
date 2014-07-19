//
//  TcpClient.h
//  Cetris
//
//  Created by Wan Wei on 14/7/19.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Client.h"

@interface TcpClient : NSObject <Client>

-(void)connect;

@end
