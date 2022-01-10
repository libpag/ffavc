#import "ViewController.h"
#import "MainView.h"
#import "BackgroundView.h"
#import <libpag/PAGVideoDecoder.h>
#import <ffavc/ffavc.h>

@interface ViewController ()

@end

@implementation ViewController {
    MainView* uiView;
    BackgroundView* backgroundView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerSoftwareDecoder];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    backgroundView = [[BackgroundView alloc] initWithFrame:screenBounds];
    [self.view addSubview:backgroundView];
    
    uiView = [[MainView alloc] initWithFrame:screenBounds];
    uiView.userInteractionEnabled = TRUE;
    [self.view addSubview:uiView];
    [uiView loadPAGAndPlay];
}
-(void)registerSoftwareDecoder
{
    // 注册软件解码器工厂指针
    auto factory = ffavc::DecoderFactory::GetHandle();
    [PAGVideoDecoder RegisterSoftwareDecoderFactory:(void*)factory];
    // 如果在真机上运行，可以解开下面这行注释，设置最大硬件解码器数量为 0，确保调用的是软件解码器。
     [PAGVideoDecoder SetMaxHardwareDecoderCount:0];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
