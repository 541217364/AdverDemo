//
//  ZLAdverManager.h
//  PracticeTest
//
//  Created by 周启磊 on 2018/9/29.
//  Copyright © 2018年 DIDIWAIMAI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZLAdverManager : NSObject

+(instancetype)shareInstance;

/**
 *  判断文件是否存在
 */
- (BOOL)isFileExistWithFilePath:(NSString *)fileName;


/**
 *  根据图片名拼接文件路径
 */
- (NSString *)getFilePathWithImageName:(NSString *)imageName;


/**
 *  新图片
 */
- (void)downloadAdImageWithUrl:(NSString *)imageUrl imageName:(NSString *)imageName;

/**
 *  新视频
 */


- (void)downloadAdmovieWithUrl:(NSString *)movieUrl movieName:(NSString *)movieName;

/**
 *  清除缓存
 */
- (void)removeCache;

/**
 *  创建documen路径下文件夹
 */

-(void)createDocumentDir:(NSString *)filePath;

@end
