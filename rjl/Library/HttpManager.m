//
//  HttpManager.m
//  TNGrabOrder
//
//  Created by 斯骏 on 15/6/30.
//  Copyright (c) 2015年 斯骏. All rights reserved.
//

#import "HttpManager.h"
#import "AFNetworking.h"

@implementation HttpManager

+ (AFHTTPSessionManager *)manager{

    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:ApiURL]];
//    manager.baseURL = [NSURL URLWithString:ApiURL];
    /**
     *  添加解析类型text/html(默认的没有添加)
     */
    manager.responseSerializer.acceptableContentTypes= [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
    
    AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
//    response.removesKeysWithNullValues = YES;
    manager.responseSerializer = response;

    return manager;
}
 
+ (void)postWithPath:(NSString *)path params:(NSDictionary *)params success:(HttpCompletionBlock)success failure:(HttpFailureBlock)failure{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
    [dict setObject:USER.device_type forKey:@"device"];
    [dict setObject:USER.client_type forKey:@"client"];
    
    if (USER && USER.user_id){
        [dict setObject:USER.token forKey:@"token"];
        [dict setObject:USER.user_id forKey:@"uid"];
    }
    AFHTTPSessionManager *manager = [HttpManager manager];
//     manager.requestSerializer = [AFJSONRequestSerializer serializer];

    [manager POST:path parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *resultDict = responseObject;
        if (resultDict) {
            if (success) {
                success(resultDict);
            }
            if (RESP_OFFLINE(resultDict)){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [TFNotificationCenter  postNotificationName: NOTI_LOGOUT object: nil];
                });
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];


}


+ (void)postWithPath:(NSString *)path params:(NSDictionary *)parames completion:(HttpCompletionBlock)completion failure:(HttpFailureBlock)failure{
    
    AFHTTPSessionManager *session = [HttpManager manager];
    session.requestSerializer.timeoutInterval = 10.0f;
//     manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:parames];
    [dict setObject:USER.device_type forKey:@"device"];
    [dict setObject:USER.client_type forKey:@"client"];
    
    if (USER && USER.user_id){
        [dict setObject:USER.token forKey:@"token"];
        [dict setObject:USER.user_id forKey:@"uid"];
    }
    
    [session POST:path parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *resultDict = responseObject;
        //        NSLog(@"success%@",resultDict);
        if (resultDict) {
            if (completion) {
                completion(resultDict);
            }
            
            if (RESP_OFFLINE(resultDict)){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [TFNotificationCenter  postNotificationName: NOTI_LOGOUT object: nil];
                });
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
    
}
+ (void)postWithPath:(NSString *)path params:(NSDictionary *)parames files:(NSDictionary *)dic success:(HttpCompletionBlock)success failure:(HttpFailureBlock)failure{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:parames];
    [dict setObject:USER.device_type forKey:@"device"];
    [dict setObject:USER.client_type forKey:@"client"];
    
    if (USER && USER.user_id){
        [dict setObject:USER.token forKey:@"token"];
        [dict setObject:USER.user_id forKey:@"uid"];
    }
    AFHTTPSessionManager *manager = [HttpManager manager];
//     manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager POST:path parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (!dic) {
            return ;
        }
        
        NSArray *keys = [dic allKeys];
        
        for (int i = 0; i<keys.count; i++) {
            
            NSString *key = keys[i];
            //压缩大小
            
            NSData *data =  dic[key];
            //时间戳命名
            NSTimeInterval time = [NSDate date].timeIntervalSince1970 * 1000;
            
            NSString *name = [NSString stringWithFormat:@"%13.0f.amr",time];
            //            NSLog(@"fileName:%@ \nfileName:%@ ",name,name);
            [formData appendPartWithFileData:data name:key fileName:name mimeType:@"audio/amr"];
            
        }
    }  progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *resultDict = responseObject;
        if (resultDict) {
            if (success) {
                success(resultDict);
            }
            if (RESP_OFFLINE(resultDict)){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [TFNotificationCenter  postNotificationName: NOTI_LOGOUT object: nil];
                });
            }
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}


#pragma mark- post带有图片的
+(void)postWithPath:(NSString *)path params:(NSDictionary *)parames images:(NSDictionary *)imageDict success:(HttpCompletionBlock)success failure:(HttpFailureBlock)failure{

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:parames];
    [dict setObject:USER.device_type forKey:@"device"];
    [dict setObject:USER.client_type forKey:@"client"];
    
    if (USER && USER.user_id){
        [dict setObject:USER.token forKey:@"token"];
        [dict setObject:USER.user_id forKey:@"uid"];
    }
    AFHTTPSessionManager *manager = [HttpManager manager];

    [manager POST:path parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

        if (!imageDict) {
            return ;
        }

        NSArray *keys = [imageDict allKeys];

        for (int i = 0; i<keys.count; i++) {

            NSString *key = keys[i];
            //压缩大小
            UIImage *imageS = [HttpManager createNewImageFrom:imageDict[key] withSize:CGSizeMake(400, 280)];
            NSData *data = UIImageJPEGRepresentation(imageS, 0.8);
            //时间戳命名
            NSTimeInterval time = [NSDate date].timeIntervalSince1970 * 1000;

            NSString *name = [NSString stringWithFormat:@"%13.0f.jpg",time];
//            NSLog(@"fileName:%@ \nfileName:%@ ",name,name);
            
            [formData appendPartWithFileData:data name:key fileName:name mimeType:@"image/jpeg"];

        }


    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {

        NSDictionary *resultDict = responseObject;
        if (resultDict) {
            if (success) {
                success(resultDict);
            }
            if (RESP_OFFLINE(resultDict)){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [TFNotificationCenter  postNotificationName: NOTI_LOGOUT object: nil];
                });
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

//        NSLog(@"上传失败 %@",error.description);
        if (failure) {
            failure(error);
        }
    }];

}
 
  /**
 *  生成指定大小的图片
 *
 */
+(UIImage *)createNewImageFrom:(UIImage *)image withSize:(CGSize)size{

  
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0f, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;

}

#pragma mark- 途鸟认证
+(void)postGrabCertification:(NSString *)path params:(NSDictionary *)parames images:(NSDictionary *)images completion:(HttpCompletionBlock)completion failure:(HttpFailureBlock)failure{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:parames];
    [dict setObject:USER.device_type forKey:@"device"];
    [dict setObject:USER.client_type forKey:@"client"];
    
    if (USER && USER.user_id){
        [dict setObject:USER.token forKey:@"token"];
        [dict setObject:USER.user_id forKey:@"uid"];
    }
    AFHTTPSessionManager *manager = [HttpManager manager];

    [manager POST:path parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

        if (!images) {
            return ;
        }

        NSArray *keys = [images allKeys];

        for (int i = 0; i<keys.count; i++) {

            NSString *key = keys[i];
            //压缩大小
            UIImage *imageS = [HttpManager createNewImageFrom:images[key] withSize:CGSizeMake(400, 280)];
            NSData *data = UIImageJPEGRepresentation(imageS, 0.8);
            //时间戳命名
            NSTimeInterval time = [NSDate date].timeIntervalSince1970;

            NSString *name = [NSString stringWithFormat:@"%10.0f.jpg",time];
//            NSLog(@"fileName:%@ \nfileName:%@ ",name,name);
            [formData appendPartWithFileData:data name:key fileName:name mimeType:@"image/jpeg"];

        }


    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {

        NSDictionary *resultDict = responseObject;
//        NSLog(@"success%@",resultDict);
        
        if (resultDict) {
            if (completion) {
                completion(resultDict);
            }
            if (RESP_OFFLINE(resultDict)){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [TFNotificationCenter  postNotificationName: NOTI_LOGOUT object: nil];
                });
            }
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError *error) {

//        NSLog(@"上传失败 %@",error.description);
        if (failure) {
            failure(error);
        }
    }];



}

#pragma mark- 注册
+(void)registerInfo:(NSDictionary *)parames faceImage:(UIImage *)image completion:(HttpCompletionBlock)completion failure:(HttpFailureBlock)failure{

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:parames];
    [dict setObject:USER.device_type forKey:@"device"];
    [dict setObject:USER.client_type forKey:@"client"];
    
    if (USER && USER.user_id){
        [dict setObject:USER.token forKey:@"token"];
        [dict setObject:USER.user_id forKey:@"uid"];
    }
    
    AFHTTPSessionManager *manager = [HttpManager manager];

    [manager POST:@"user/get_regiter_info" parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

        if (!image) {
            return ;
        }
        //压缩大小
        UIImage *imageS = [HttpManager createNewImageFrom:image withSize:CGSizeMake(400, 280)];
        NSData *data = UIImageJPEGRepresentation(imageS, 0.8);
        //时间戳命名
        NSTimeInterval time = [NSDate date].timeIntervalSince1970;

        NSString *name = [NSString stringWithFormat:@"%10.0f.jpg",time];
//        NSLog(@"fileName:%@ \nfileName:%@ ",name,name);
       [formData appendPartWithFileData:data name:@"face" fileName:name mimeType:@"image/jpeg"];


    } progress:nil success:^(NSURLSessionDataTask * _Nonnull operation, id responseObject) {

        NSDictionary *resultDict = responseObject;
//        NSLog(@"success%@",resultDict);
        if (resultDict) {
            if (completion) {
                completion(resultDict);
            }
            if (RESP_OFFLINE(resultDict)){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [TFNotificationCenter  postNotificationName: NOTI_LOGOUT object: nil];
                });
            }
        } 
    } failure:^(NSURLSessionDataTask * _Nonnull operation, NSError *error) {

//        NSLog(@"上传失败 %@",error.description);
        if (failure) {
            failure(error);
        }
    }];
}

@end
