//
//  RNPedometer.h
//  RNPedometer
//
//  Created by galmis on 02/04/2016.
//  Copyright © 2016 galmis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "RCTBridgeModule.h"

@interface RNPedometer : NSObject <RCTBridgeModule>

@property (nonatomic, readonly) CMPedometer *pedometer;

@end
