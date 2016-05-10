//
//  ViewController.m
//  drawereffect
//
//  Created by issuser on 16/3/9.
//  Copyright © 2016年 issuser. All rights reserved.
//

#import "ViewController.h"
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define MAXYOFFSET 100
#define ENDRIGHTX 170
#define ENDLEFTX -170
@interface ViewController ()
@property(nonatomic,strong)UIView * redView;
@property(nonatomic,strong)UIView * blueView;
@property(nonatomic,strong)UIView * greenView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setUpThreeViews];
    
    // 利用KVO时刻监听_redView.frame改变
    // Observer:谁需要观察
    // KeyPath：监听的属性名称
    // options: NSKeyValueObservingOptionNew监听这个属性新值
    [_redView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}


- (void)setUpThreeViews{
    UIView * blueView = [[UIView alloc]initWithFrame:self.view.bounds];
    blueView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:blueView];
    _blueView = blueView;
    
    UIView * greenView = [[UIView alloc]initWithFrame:self.view.bounds];
    greenView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:greenView];
    _greenView = greenView;
    
    UIView * redView = [[UIView alloc]initWithFrame:self.view.bounds];
    redView.backgroundColor = [UIColor redColor];
    [self.view addSubview:redView];
    _redView = redView;
    
}



- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch * touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:_redView];//获得当前redview的点
    CGPoint prePoint = [touch previousLocationInView:_redView];//获得起点
    CGFloat  moveX = currentPoint.x - prePoint.x;//获得X轴方向的偏移量
    
    NSLog(@"当前点：%f---起点：%f--偏移量：%f",currentPoint.x,prePoint.x,moveX);
//通过x轴方向的偏移量获得view的frame
    _redView.frame = [self frameWithOffsetX:moveX];//
}

- (CGRect)frameWithOffsetX:(CGFloat)offsetX{
    
    //计算在y轴方向上的偏移量
    CGFloat offsetY = offsetX/SCREENWIDTH * MAXYOFFSET;
    //根据y方向的偏移量计算缩放比例
    CGFloat scale = (SCREENHEIGHT - 2*offsetY)/SCREENHEIGHT;
    //如果x < 0表示左滑
    if (_redView.frame.origin.x < 0) {
        scale = (SCREENHEIGHT + 2*offsetY)/SCREENHEIGHT;
    }
    
    CGRect frame = _redView.frame;
    //计算滑动之后的frame
    CGFloat height = frame.size.height*scale;
    CGFloat width  = frame.size.width;
    CGFloat x = frame.origin.x + offsetX;
    CGFloat y = (SCREENHEIGHT- height)* 0.5;
    
    return CGRectMake(x, y, width, height);
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGFloat xPos = _redView.frame.origin.x;
    //大于屏幕的一半进入新的位置
    if (xPos > SCREENWIDTH*0.5) {
        [UIView animateWithDuration:0.5 animations:^{
            self.redView.frame = [self framWithBigThanX:ENDRIGHTX];
        }];
        return ;
    }
    //小于屏幕的一半，大于屏幕负一半的时候，则恢复到初始状态
    if (xPos < SCREENWIDTH*0.5 && xPos > -SCREENWIDTH*0.5) {
        [UIView animateWithDuration:0.5 animations:^{
            self.redView.frame = [UIScreen mainScreen].bounds;
        }];
        return ;
    }
    //xPos < -SCREENWIDTH*0.5的时候，进入新的位置
    [UIView animateWithDuration:0.5 animations:^{
        self.redView.frame =  [self framWithSmallThanX:ENDLEFTX];
    }];
    
}

- (CGRect)framWithBigThanX:(CGFloat)offsetX
{
    
    CGFloat offsetY = offsetX/SCREENWIDTH * MAXYOFFSET;
    CGFloat scale = (SCREENHEIGHT - 2*offsetY)/SCREENHEIGHT;
    
    CGFloat height = SCREENHEIGHT*scale;
    CGFloat width  = SCREENWIDTH;
    CGFloat x = offsetX;
    CGFloat y = (SCREENHEIGHT- height)* 0.5;
    
    return CGRectMake(x, y, width, height);
}

- (CGRect)framWithSmallThanX:(CGFloat)offsetX
{
    CGFloat offsetY = offsetX/SCREENWIDTH * MAXYOFFSET;
    CGFloat scale = (SCREENHEIGHT + 2*offsetY)/SCREENHEIGHT;
    
    CGFloat height = SCREENHEIGHT*scale;
    CGFloat width  = SCREENWIDTH;
    CGFloat x = offsetX;
    CGFloat y = (SCREENHEIGHT- height)* 0.5;
    
    return CGRectMake(x, y, width, height);
}

// 只要监听的属性有新值的时候，只要redView.frame一改变就会调用
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.redView.frame.origin.x > 0) {
        _greenView.hidden = NO;
    } else if(self.redView.frame.origin.x < 0){
        _greenView.hidden = YES;
    }
}



// 当对象销毁的时候，一定要移除观察者
- (void)dealloc
{
    [_redView removeObserver:self forKeyPath:@"frame"];
}
@end
