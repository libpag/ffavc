#import "MainView.h"
#import <libpag/PAGView.h>

@implementation MainView {
    PAGView* pagView;
    NSString* pagPath;
}


- (void)loadPAGAndPlay {
    if (pagView != nil) {
        [pagView stop];
        [pagView removeFromSuperview];
        pagView = nil;
    }

    pagPath = [[NSBundle mainBundle] pathForResource:@"particle_video" ofType:@"pag"];
    pagView = [[PAGView alloc] init];
    pagView.frame = self.frame;
    [self addSubview:pagView];
    PAGFile* pagFile = [PAGFile Load:pagPath];
    [pagView setComposition:pagFile];
    [pagView setRepeatCount:-1];
    [pagView play];
}


- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    if ([pagView isPlaying]) {
        [pagView stop];
    } else {
        [pagView play];
    }

}


@end
