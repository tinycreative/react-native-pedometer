//
//  RNPedometer.m
//  RNPedometer
//
//  Created by galmis on 02/04/2016.
//  Copyright © 2016 galmis. All rights reserved.
//

#import "RNPedometer.h"

#import <CoreMotion/CoreMotion.h>
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"

#define NullErr [NSNull null]

@interface RNPedometer ()
@property (nonatomic, readonly) CMPedometer *pedometer;
@end


@implementation RNPedometer

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

- (NSDictionary *)constantsToExport {
  return @{
    @"isStepCountingAvailable" : @([CMPedometer isStepCountingAvailable]),
    @"isFloorCountingAvailable" : @([CMPedometer isFloorCountingAvailable]),
    @"isDistanceAvailable" : @([CMPedometer isDistanceAvailable])
  };
}

RCT_EXPORT_METHOD(isStepCountingAvailable:(RCTResponseSenderBlock) callback) {
    callback(@[NullErr, @([CMPedometer isStepCountingAvailable])]);
}

RCT_EXPORT_METHOD(isFloorCountingAvailable:(RCTResponseSenderBlock) callback) {
    callback(@[NullErr, @([CMPedometer isFloorCountingAvailable])]);
}

RCT_EXPORT_METHOD(isDistanceAvailable:(RCTResponseSenderBlock) callback) {
    callback(@[NullErr, @([CMPedometer isDistanceAvailable])]);
}

RCT_EXPORT_METHOD(queryPedometerDataBetweenDates:(NSDate *)startDate endDate:(NSDate *)endDate handler:(RCTResponseSenderBlock)handler) {
    [self.pedometer queryPedometerDataFromDate:startDate
                                        toDate:endDate
                                   withHandler:^(CMPedometerData *pedometerData, NSError *error) {
                                       handler(@[error.description?:NullErr, [self dictionaryFromPedometerData:pedometerData]]);
                                   }];
}

RCT_EXPORT_METHOD(startPedometerUpdatesFromDate:(NSDate *)date) {
    [self.pedometer startPedometerUpdatesFromDate:date?:[NSDate date]
                                      withHandler:^(CMPedometerData *pedometerData, NSError *error) {
                                          if (pedometerData) {
                                              [[self.bridge eventDispatcher] sendDeviceEventWithName:@"pedometerDataDidUpdate" body:[self dictionaryFromPedometerData:pedometerData]];
                                          }
                                      }];
}

- (NSDictionary *)dictionaryFromPedometerData:(CMPedometerData *)data {

    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ";
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    });
    return @{
             @"startDate": [formatter stringFromDate:data.startDate]?:NullErr,
             @"endDate": [formatter stringFromDate:data.endDate]?:NullErr,
             @"numberOfSteps": data.numberOfSteps?:NullErr,
             @"distance": data.distance?:NullErr,
             @"floorsAscended": data.floorsAscended?:NullErr,
             @"floorsDescended": data.floorsDescended?:NullErr,
           };
}

RCT_EXPORT_METHOD(stopPedometerUpdates) {
    [self.pedometer stopPedometerUpdates];
}

#pragma mark - Private

- (instancetype)init
{
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _pedometer = [[CMPedometer alloc]init];

    return self;
}


@end
