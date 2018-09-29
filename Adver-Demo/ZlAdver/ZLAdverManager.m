//
//  ZLAdverManager.m
//  PracticeTest
//
//  Created by 周启磊 on 2018/9/29.
//  Copyright © 2018年 DIDIWAIMAI. All rights reserved.
//

#import "ZLAdverManager.h"

@implementation ZLAdverManager

+(instancetype)shareInstance{
    
    static ZLAdverManager *manager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[ZLAdverManager alloc]init];
    });
    return  manager;
}


- (BOOL)isFileExistWithFilePath:(NSString *)fileName{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = FALSE;
    NSString *filePath = [self getFilePathWithImageName:fileName];
    return [fileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
}


- (void)downloadAdImageWithUrl:(NSString *)imageUrl imageName:(NSString *)imageName{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        
        UIImage *image = [UIImage imageWithData:data];
        
        NSString *filePath = [self getFilePathWithImageName:imageName]; // 保存文件的名称
        
        if ([UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES]) {// 保存成功
            NSLog(@"保存成功");
           
            
            // 如果有广告链接，将广告链接也保存下来
        }else{
            NSLog(@"保存失败");
        }
        
    });
}






/**
 *  新视频
 */

- (void)downloadAdmovieWithUrl:(NSString *)movieUrl movieName:(NSString *)movieName
{
    
    NSString *path = [self getFilePathWithImageName:movieName];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:movieUrl]];
        
        if ([data writeToFile:path atomically:YES]) {
            // 保存成功
           
            
        }else{
            
            NSLog(@"保存失败");
        }
        
    });
    
}




/**
 *  根据图片名拼接文件路径
 */
- (NSString *)getFilePathWithImageName:(NSString *)imageName
{
    if (imageName) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
        NSLog(@"%@ --- %@",paths,filePath);
        return filePath;
    }
    
    return nil;
}


- (void)removeCache{
    //===============清除缓存==============
    //获取路径
    NSString*cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES)objectAtIndex:0];
    //返回路径中的文件数组
    NSArray*files = [[NSFileManager defaultManager]subpathsAtPath:cachePath];
    NSLog(@"文件数：%ld",[files count]);
    for(NSString *p in files){ NSError*error;
        NSString*path = [cachePath stringByAppendingString:[NSString stringWithFormat:@"/%@",p]];
        if([[NSFileManager defaultManager]fileExistsAtPath:path]) { BOOL isRemove = [[NSFileManager defaultManager]removeItemAtPath:path error:&error];
            if(isRemove)
            {
                NSLog(@"清除成功");
                //这里发送一个通知给外界，外界接收通知，可以做一些操作（比如UIAlertViewController）
                
            }else{
                NSLog(@"清除失败");
                
            }
            
        }
        
    }
    
}


//创建Document路径下文件夹
-(void)createDocumentDir:(NSString *)filePath{
    
    if (filePath == nil || filePath.length == 0) {
        
        return;
    }
    //获取Document文件
    NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * rarFilePath = [docsdir stringByAppendingPathComponent:filePath];//将需要创建的串拼接到后面
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:rarFilePath isDirectory:&isDir];
   
    if ( !(isDir == YES && existed == YES) ) {//如果文件夹不存在
        [fileManager createDirectoryAtPath:rarFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    
}

@end
