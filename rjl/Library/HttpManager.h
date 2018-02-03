//
//  HttpManager.h
//  TNGrabOrder
//
//  Created by 斯骏 on 15/6/30.
//  Copyright (c) 2015年 斯骏. All rights reserved.
//

#import <Foundation/Foundation.h> 

 


typedef void (^HttpCompletionBlock)(id JSON);
typedef void (^HttpFailureBlock)(NSError *error);
@interface HttpManager : NSObject
 
#pragma mark- postWithPath
+(void)postWithPath:(NSString *)path params:(NSDictionary *)params success:(HttpCompletionBlock)success failure:(HttpFailureBlock)failure;


+(void)postWithPath:(NSString *)path params:(NSDictionary *)parames completion:(HttpCompletionBlock)completion failure:(HttpFailureBlock)failure;


#pragma mark- 取货验证码
//+(void)InputVerificationCode:(NSString *)path params:(NSDictionary *)parames images:(NSDictionary *)images completion:(HttpCompletionBlock)completion failure:(HttpFailureBlock)failure;
#pragma mark- post带有图片的
+(void)postWithPath:(NSString *)path params:(NSDictionary *)parames images:(NSDictionary *)imageDict success:(HttpCompletionBlock)success failure:(HttpFailureBlock)failure;


+(void)postWithPath:(NSString *)path params:(NSDictionary *)parames files:(NSDictionary *)dic success:(HttpCompletionBlock)success failure:(HttpFailureBlock)failure;

#pragma mark- 途鸟认证
+(void)postGrabCertification:(NSString *)path params:(NSDictionary *)parames images:(NSDictionary *)images completion:(HttpCompletionBlock)completion failure:(HttpFailureBlock)failure;
@end
