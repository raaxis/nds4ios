//
//  NDSEmulatorViewController.m
//  nds4ios
//
//  Created by InfiniDev on 6/11/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import "NDSEmulatorViewController.h"
#import "GLProgram.h"

#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>

#include "emu.h"

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

NSString *const kVertShader = SHADER_STRING
(
 attribute vec4 position;
 attribute vec2 inputTextureCoordinate;
 
 varying highp vec2 texCoord;
 
 void main()
 {
     texCoord = inputTextureCoordinate;
     gl_Position = position;
 }
 );

NSString *const kFragShader = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 varying highp vec2 texCoord;
 
 void main()
 {
     highp vec4 color = texture2D(inputImageTexture, texCoord);
     gl_FragColor = color;
 }
 );

const float positionVert[] =
{
    -1.0f, 1.0f,
    1.0f, 1.0f,
    -1.0f, -1.0f,
    1.0f, -1.0f
};

const float textureVert[] =
{
    0.0f, 0.0f,
    1.0f, 0.0f,
    0.0f, 1.0f,
    1.0f, 1.0f
};

@interface NDSEmulatorViewController () <GLKViewDelegate> {
    int fps;
    
    GLuint texHandle;
    GLint attribPos;
    GLint attribTexCoord;
    GLint texUniform;
}

@property (weak, nonatomic) IBOutlet UILabel *fpsLabel;
@property (strong, nonatomic) GLProgram *program;
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) IBOutlet GLKView *glkView;
@property (weak, nonatomic) IBOutlet UIView *controllerContainerView;

@end

@implementation NDSEmulatorViewController
{
    NSLock *emuLoopLock;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.multipleTouchEnabled = YES;
    
    [self loadROM];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseEmulation) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeEmulation) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    self.controllerContainerView.alpha = 0.5f;
}

- (void)viewWillAppear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Playing ROM

- (void)loadROM {
    EMU_setWorkingDir([[self.romFilepath stringByDeletingLastPathComponent] UTF8String]);
    EMU_init();
    EMU_loadRom([self.romFilepath UTF8String]);
    EMU_change3D(1);
    
    EMU_enableSound(YES);
    
    [self initGL];
    
    emuLoopLock = [NSLock new];
    
    [self startEmulatorLoop];
}

- (void)initGL
{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.context];
    
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, 480.0f); // Temporarily hardcoding 480 to keep aspect ratio the same for all non-iPad iOS Devices
    
    self.glkView = [[GLKView alloc] initWithFrame:frame context:self.context];
    self.glkView.delegate = self;
    [self.view insertSubview:self.glkView atIndex:0];
    
    self.program = [[GLProgram alloc] initWithVertexShaderString:kVertShader fragmentShaderString:kFragShader];
    
    [self.program addAttribute:@"position"];
	[self.program addAttribute:@"inputTextureCoordinate"];
    
    [self.program link];
    
    attribPos = [self.program attributeIndex:@"position"];
    attribTexCoord = [self.program attributeIndex:@"inputTextureCoordinate"];
    
    texUniform = [self.program uniformIndex:@"inputImageTexture"];
    
    glEnableVertexAttribArray(attribPos);
    glEnableVertexAttribArray(attribTexCoord);
    
    float scale = [UIScreen mainScreen].scale;
    CGSize size = CGSizeMake(self.glkView.bounds.size.width * scale, self.glkView.bounds.size.height * scale);
    
    glViewport(0, 0, size.width, size.height);
    
    [self.program use];
    
    glGenTextures(1, &texHandle);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, texHandle);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

- (void)shutdownGL
{
    glDeleteTextures(1, &texHandle);
    texHandle = 0;
    self.context = nil;
    self.program = nil;
    [self.glkView removeFromSuperview];
    self.glkView = nil;
    [EAGLContext setCurrentContext:nil];
}

- (UIImage*)screenSnapshot
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CFDataRef videoData = CFDataCreate(NULL, (UInt8*)video.buffer, video.size()*4);
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(videoData);
    CGImageRef screenImage = CGImageCreate(256, 384, 8, 32, 256*4, colorSpace, kCGBitmapByteOrderDefault, dataProvider, NULL, false, kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(dataProvider);
    CFRelease(videoData);
    
    UIImage *image = [UIImage imageWithCGImage:screenImage];
    CGImageRelease(screenImage);
    return image;
}

- (void)pauseEmulation
{
    if (!execute) return;
    // save snapshot of screen
    if (self.snapshotView == nil) {
        self.snapshotView = [[UIImageView alloc] initWithFrame:self.glkView.frame];
        [self.view insertSubview:self.snapshotView aboveSubview:self.glkView];
    } else {
        self.snapshotView.hidden = NO;
    }
    self.snapshotView.image = [self screenSnapshot];
    
    // pause emulation
    EMU_pause(true);
    [emuLoopLock lock]; // make sure emulator loop has ended
    [emuLoopLock unlock];
    [self shutdownGL];
}

- (void)resumeEmulation
{
    if (execute) return;
    // remove snapshot
    self.snapshotView.hidden = YES;
    
    // resume emulation
    [self initGL];
    EMU_pause(false);
    [self startEmulatorLoop];
}

- (void)startEmulatorLoop
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [emuLoopLock lock];
        while (execute) {
            EMU_runCore();
            fps = EMU_runOther();
            EMU_copyMasterBuffer();
            
            [self updateDisplay];
        }
        [emuLoopLock unlock];
    });
}

- (void)updateDisplay
{
    if (texHandle == 0) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.fpsLabel.text = [NSString stringWithFormat:@"%d FPS",fps];
    });
    
    glBindTexture(GL_TEXTURE_2D, texHandle);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 256, 384, 0, GL_RGBA, GL_UNSIGNED_BYTE, &video.buffer);
    
    [self.glkView display];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, texHandle);
    glUniform1i(texUniform, 1);
    
    glVertexAttribPointer(attribPos, 2, GL_FLOAT, 0, 0, (const GLfloat*)&positionVert);
    glVertexAttribPointer(attribTexCoord, 2, GL_FLOAT, 0, 0, (const GLfloat*)&textureVert);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

#pragma mark - Controls

- (IBAction)pressedDPad:(NDSDirectionalControl *)sender
{
    UIControlState state = sender.direction;
    EMU_setDPad(state & NDSDirectionalControlDirectionUp, state & NDSDirectionalControlDirectionDown, state & NDSDirectionalControlDirectionLeft, state & NDSDirectionalControlDirectionRight);
}

- (IBAction)pressedABXY:(NDSButtonControl *)sender
{
    UIControlState state = sender.selectedButtons;
    EMU_setABXY(state & NDSButtonControlButtonA, state & NDSButtonControlButtonB, state & NDSButtonControlButtonX, state & NDSButtonControlButtonY);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.glkView];
    
    if (point.y < self.glkView.bounds.size.height/2) {
        return;
    }
    
    NSLog(@"Touch screen tapped");
    
    point.x /= 1.33f;
    point.y -= 240.0f;
    point.y /= 1.33f;
    
    EMU_touchScreenTouch(point.x, point.y);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.glkView];
    
    if (point.y < self.glkView.bounds.size.height/2) {
        return;
    }
    
    NSLog(@"Touch screen moved!");
    
    point.x /= 1.33f;
    point.y -= 240.0f;
    point.y /= 1.33f;
    
    EMU_touchScreenTouch(point.x, point.y);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touch screen released");
    EMU_touchScreenRelease();
}

- (void)viewDidUnload {
    [self setButtonControl:nil];
    [self setDirectionalControl:nil];
    [self setControllerContainerView:nil];
    [super viewDidUnload];
}
@end
