//
//  CredentialStore.h
//  ColaNews
//
//  Created by Wan Wei on 1/29/14.
//  Copyright (c) 2014 Wan Wei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CredentialStore : NSObject

+ (id)sharedStore;

- (BOOL) isLoggedIn;
- (void) clearSavedCredentials;

- (NSString *) authToken;
- (void) setAuthToken:(NSString *) authToken;

@property (strong, nonatomic) NSString* userId;
@property (strong, nonatomic) NSString* userName;
@property (strong, nonatomic) NSString* password;
@property (strong, nonatomic) NSString* authTokenExpires;
@property (strong, nonatomic) NSString* deviceToken;

@property (strong, nonatomic) NSString* defaultCircleId;
@property (strong, nonatomic) NSString* defaultCircleName;

@end
