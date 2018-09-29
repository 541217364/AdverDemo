//
//  ZLAdvertisementController.m
//  PracticeTest
//
//  Created by 周启磊 on 2018/9/28.
//  Copyright © 2018年 DIDIWAIMAI. All rights reserved.
//

#import "ZLAdvertisementController.h"
#import <AVFoundation/AVFoundation.h>
#import "ZLAdverManager.h"
#import "ViewController.h"

#define IS_3_5_INCH          ([[UIScreen mainScreen] bounds].size.width == 320 && [[UIScreen mainScreen] bounds].size.height == 480 ? YES:NO)
#define IS_4_0_INCH          ([[UIScreen mainScreen] bounds].size.width == 320 && [[UIScreen mainScreen] bounds].size.height == 568 ? YES:NO)
#define IS_4_7_INCH          ([[UIScreen mainScreen] bounds].size.width == 375 && [[UIScreen mainScreen] bounds].size.height == 667 ? YES:NO)
#define IS_5_5_INCH          ([[UIScreen mainScreen] bounds].size.width == 414 && [[UIScreen mainScreen] bounds].size.height == 736 ? YES:NO)

#define screen_width [[UIScreen mainScreen] bounds].size.width
#define screen_height [[UIScreen mainScreen] bounds].size.height

// 广告显示的时间
static int const showtime = 4;

static NSString *imagePath = @"https://img.dianbeiwaimai.cn/upload/store/000/004/904/5ba216227da46520.png";

static NSString *moviePath = @"http://118.31.11.208//upload//guide_1.mp4";

@interface ZLAdvertisementController ()<UIScrollViewDelegate>

@property (nonatomic, strong) NSTimer *countTimer;

@property (nonatomic, strong) UIImageView *contentimageView;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, retain)AVPlayerLayer *playerLayer; //提供播放层

@property (nonatomic, retain)AVPlayer *player; //存储播放器对象

@property(nonatomic,strong)UIScrollView *myscrollView;

@property(nonatomic,strong)UIView *mymovieView;//视频播放视图

@property (nonatomic, assign) int count;

@property (nonatomic, assign)BOOL isReadToPlay;//视频播放状态

@property(nonatomic,strong)UIButton *returnBtn;

@end

@implementation ZLAdvertisementController
{
    
    UIPageControl *pageControll;
    
}


- (NSTimer *)countTimer
{
    if (!_countTimer) {
        _countTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    }
    return _countTimer;
}

-(UIScrollView *)myscrollView{
    
    if (_myscrollView == nil) {
        _myscrollView = [[UIScrollView alloc]init];
        _myscrollView.backgroundColor = [UIColor clearColor];
        _myscrollView.frame = CGRectMake(0, 0, screen_width, screen_height);
        _myscrollView.contentSize = CGSizeMake(screen_width * 5, 0);
        _myscrollView.bounces = NO;
        _myscrollView.delegate = self;
        _myscrollView.showsVerticalScrollIndicator = NO;
        _myscrollView.showsHorizontalScrollIndicator = NO;
        _myscrollView.pagingEnabled = YES;
    }
    return _myscrollView;
}

-(UIView *)mymovieView{
    
    if (_mymovieView == nil) {
        _mymovieView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screen_width, screen_height)];
        _mymovieView.backgroundColor = [UIColor whiteColor];
    }
    return _mymovieView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    
}

- (void)initUI
{
    
    [self.view addSubview:self.contentimageView];
    
    CGFloat btnW = 60;
    CGFloat btnH = 30;
    self.returnBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - btnW - 24, btnH, btnW, btnH)];
    [_returnBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_returnBtn setTitle:[NSString stringWithFormat:@"跳过%d", showtime] forState:UIControlStateNormal];
    _returnBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_returnBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _returnBtn.backgroundColor = [UIColor colorWithRed:38 /255.0 green:38 /255.0 blue:38 /255.0 alpha:0.6];
    _returnBtn.layer.cornerRadius = 4;
    [self.view addSubview:self.returnBtn];
    
    [NSThread sleepForTimeInterval:1.5];
    
    
}


// 定时器倒计时
- (void)startTimer
{
    _count = showtime;
    [[NSRunLoop mainRunLoop] addTimer:self.countTimer forMode:NSRunLoopCommonModes];
}


- (void)setAdtype:(NSInteger)adtype{
    
    if (adtype) {
        
        _adtype = adtype;
        
        switch (adtype) {
            case 1:
                
                [self lunchSinglePhoto];
                
                break;
                
            case 2:
                
                [self lunchMorePhotos];
                
                break;
                
            case 3:
                
                [self lunchMovie];
                
                break;
                
            default:
                break;
        }
    }
}



//单张图片显示

-(void)lunchSinglePhoto{
    
    NSArray *stringArr = [imagePath componentsSeparatedByString:@"/"];
    NSString *imageName = stringArr.lastObject;
    
    if ([[ZLAdverManager shareInstance] isFileExistWithFilePath:imageName]) {
        
        NSString *filePath = [[ZLAdverManager shareInstance]getFilePathWithImageName:imageName];
        self.imageView.image = [UIImage imageWithContentsOfFile:filePath];
        [self.view addSubview:self.imageView];
        [self.view bringSubviewToFront:self.returnBtn];
        [self startTimer];
        
    }else{
        
        [[ZLAdverManager shareInstance] downloadAdImageWithUrl:imagePath imageName:imageName];
        [self dismiss];
    }
}


//多张图片显示
-(void)lunchMorePhotos{
    
    [self.view addSubview:self.myscrollView];
    [self designViewWithFrame:self.view.bounds];
    [self.view bringSubviewToFront:self.returnBtn];
    [self startTimer];
    
}

//启动视频显示
-(void)lunchMovie{
    
    NSArray *stringArr = [moviePath componentsSeparatedByString:@"/"];
    NSString *movieName = stringArr.lastObject;
    
    if ([[ZLAdverManager shareInstance] isFileExistWithFilePath:movieName]) {
        
        NSString *filePath = [[ZLAdverManager shareInstance]getFilePathWithImageName:movieName];
        
        [self.view addSubview:self.mymovieView];
        [self playWithVideolink:filePath];
        [self.view bringSubviewToFront:self.returnBtn];
        [self startTimer];
        
    }else{
        
        [[ZLAdverManager shareInstance] downloadAdmovieWithUrl:moviePath movieName:movieName];
        [self dismiss];
    }
    
}


-(void)playWithVideolink:(NSString *)videolink{
    
    //2.文件的url
    NSURL * url = [NSURL fileURLWithPath:videolink];
    
    AVPlayerItem *item = [[AVPlayerItem alloc]initWithURL:url];
    //3.根据url创建播放器(player本身不能显示视频)
    AVPlayer * player = [AVPlayer playerWithPlayerItem:item];
    
    //4.根据播放器创建一个视图播放的图层
    AVPlayerLayer * layer = [AVPlayerLayer playerLayerWithPlayer:player];
    
    layer.videoGravity = AVLayerVideoGravityResize;
    
    //5.设置图层的大小
    layer.frame = self.view.bounds;
    
    //6.添加到控制器的view的图层上面
    [self.mymovieView.layer addSublayer:layer];
    
    self.mymovieView.layer.backgroundColor = (__bridge CGColorRef _Nullable)([UIColor blackColor]);
    
    //监听视频状态
     [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    //7.开始播放
    
    [player play];
        
    
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:
(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        //取出status的新值
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey]intValue];
        switch (status) {
            case AVPlayerItemStatusFailed:
               
                self.isReadToPlay = NO;
                break;
            case AVPlayerItemStatusReadyToPlay:
                NSLog(@"准好播放了");
                self.isReadToPlay = YES;
               
                break;
            case AVPlayerItemStatusUnknown:
                NSLog(@"视频资源出现未知错误");
                self.isReadToPlay = NO;
                break;
            default:
                break;
        }
    }
    //移除监听（观察者）
    [object removeObserver:self forKeyPath:@"status"];
}



#pragma mark 布局界面

-(void)designViewWithFrame:(CGRect)Frame {
 
    for (int i = 0; i < 5; i ++) {
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.userInteractionEnabled = YES;
        imageView.frame = CGRectMake(screen_width * i, 0, screen_width, screen_height);
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"leadpage%d",i + 1]];
        [_myscrollView addSubview:imageView];
        if (i != 4) {
            UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            leftBtn.frame = CGRectMake(screen_width -60, 30, 50, 50);
            leftBtn.backgroundColor = [UIColor clearColor];
            [imageView addSubview:leftBtn];
            [leftBtn addTarget:self action:@selector(handleClick) forControlEvents:UIControlEventTouchUpInside];
        }else if (i == 4) {
            UIButton *openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            openBtn.frame = CGRectMake(50, screen_height -200, screen_width -100, 200);
            openBtn.backgroundColor = [UIColor clearColor];
            [imageView addSubview:openBtn];
            [openBtn addTarget:self action:@selector(handleClick) forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
    
    
    pageControll = [[UIPageControl alloc]initWithFrame:CGRectMake((screen_width - 60) /2, screen_height- 60, 60, 20)];
    pageControll.pageIndicatorTintColor = [UIColor whiteColor];
    pageControll.currentPageIndicatorTintColor = [UIColor redColor];
    [pageControll addTarget:self action:@selector(clickPageControll:) forControlEvents:UIControlEventValueChanged];
    pageControll.numberOfPages = 5;
    pageControll.currentPage = 0;
    [self.view addSubview:pageControll];
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [pageControll setCurrentPage:scrollView.contentOffset.x / screen_width];
    
}


-(void)handleClick{
    
    [self dismiss];
}

-(void)clickPageControll:(UIPageControl *)pageControll{
    
    [_myscrollView setContentOffset:CGPointMake(screen_width * pageControll.currentPage, 0) animated:YES];
}



- (void)countDown
{
    _count --;
    [_returnBtn setTitle:[NSString stringWithFormat:@"跳过%d",_count] forState:UIControlStateNormal];
    
    if (_count == 0) {
        
        [self dismiss];
    }
}

// 移除广告页面
- (void)dismiss
{
    [self.countTimer invalidate];
    
    self.countTimer = nil;
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.view.alpha = 0.5f;
        
    } completion:^(BOOL finished) {
        
        ViewController *VC = [[ViewController alloc]init];
        
        UIWindow *window = [[UIApplication sharedApplication] delegate].window;
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            window.rootViewController = VC;
            
        });
        
        
    }];
    
}



- (UIImageView *)imageView
{
    if (!_imageView) {
        UIWindow *mainWindow = [UIApplication sharedApplication].delegate.window;
        _imageView = [[UIImageView alloc] initWithFrame:mainWindow.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.contentMode = UIViewContentModeScaleToFill;
    }
    
    return _imageView;
}


- (UIImageView *)contentimageView
{
    if (!_contentimageView) {
        UIWindow *mainWindow = [UIApplication sharedApplication].delegate.window;
        _contentimageView = [[UIImageView alloc] initWithFrame:mainWindow.bounds];
        _contentimageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _contentimageView.contentMode = UIViewContentModeScaleToFill;
        _contentimageView.image = [self launchImage];
    }
    
    return _contentimageView;
}


- (UIImage *)launchImage
{
    UIImage *image = nil;
    
    if (IS_5_5_INCH) {
        image = [UIImage imageNamed:@"LaunchImage-800-Portrait-736h"];
    } else if (IS_4_7_INCH) {
        image = [UIImage imageNamed:@"LaunchImage-800-Portrait-736h"];
    } else if (IS_4_0_INCH) {
        image = [UIImage imageNamed:@"LaunchImage-750-1334h"];
       
    } else if (IS_3_5_INCH) {
        image = [UIImage imageNamed:@"LaunchImage-700"];
    }
    
    return image;
}

@end
