/******************************************************************************
 *
 *       Copyright Zebra Technologies, Inc. 2014 - 2015
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Zebra Technologies
 *       Confidential Proprietary Information.
 *
 *
 *  Description:  BatteryIndicatorView.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "BatteryIndicatorView.h"

#define ZT_VC_BATTERY_INDICATOR_UNIT          0.73

@implementation zt_BatteryIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (nil != self)
    {
        m_BatteryLevel = 10;
        m_IsCharging = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (nil != self)
    {
        m_BatteryLevel = 10;
        m_IsCharging = NO;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //CGContextSetLineWidth(context, 4.0);
    //CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
    //CGContextAddRect(context, self.frame);
    //CGContextStrokePath(context);
    
    
    float x = 0.0;
    float y = 0.0;
    float width = 0.0;
    float height = 0.0;
    
    float view_width = self.bounds.size.width;
    float view_height = self.bounds.size.height;

    float unit = ZT_VC_BATTERY_INDICATOR_UNIT*view_height/100.0;
    
    UIBezierPath *rounded_path = nil;
    
    /* draw background */
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0.0, view_width, view_height));
    
    /* draw top */
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    rounded_path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.3*view_width, 0.0, 0.4*view_width, 7*unit + 2*unit) cornerRadius:unit];
    [rounded_path fill];
    
    /* draw body */
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    rounded_path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 7*unit, view_width, view_height - 7*unit) cornerRadius:3*unit];
    [rounded_path fill];
    
    UIColor *color_50_100 = [UIColor greenColor];
    UIColor *color_30_50 = [UIColor yellowColor];
    UIColor *color_10_30 = [UIColor orangeColor];
    UIColor *color_0_10 = [UIColor redColor];
    UIColor *current_color = nil;
    
    x = 2*unit;
    width = view_width - 4*unit;
    height = 10*unit;
    
    y = view_height - 4*unit;
    
    if (NO == m_IsCharging)
    {
        int _stop_level = m_BatteryLevel / 10 + (((m_BatteryLevel % 10) > 2) ? 1 : 0);
        
        if (_stop_level == 0)
        {
            _stop_level++;
        }
        
        for (int i = 0; i < 10; i++)
        {
            if (i >= _stop_level)
            {
                break;
            }
            
            if (i < 1)
            {
                if (_stop_level <= 1)
                {
                    current_color = color_0_10;
                }
                else if (_stop_level <= 3)
                {
                    current_color = color_10_30;
                }
                else if (_stop_level <= 5)
                {
                    current_color = color_30_50;
                }
                else
                {
                    current_color = color_50_100;
                }
            }
            else if (i < 3)
            {
                if (_stop_level <= 3)
                {
                    current_color = color_10_30;
                }
                else if (_stop_level <= 5)
                {
                    current_color = color_30_50;
                }
                else
                {
                    current_color = color_50_100;
                }
            }
            else if (i < 5)
            {
                if (_stop_level <= 5)
                {
                    current_color = color_30_50;
                }
                else
                {
                    current_color = color_50_100;
                }
            }
            else
            {
                current_color = color_50_100;
            }
            
            CGContextSetFillColorWithColor(ctx, current_color.CGColor);
            rounded_path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y - (i+1)*(height + 2*unit), width, height) cornerRadius:unit];
            [rounded_path fill];
        }
    }
    else
    {
        for (int i = 0; i < 10; i++)
        {
            if (i >= m_ChargingLevel)
            {
                break;
            }
            CGContextSetFillColorWithColor(ctx, color_50_100.CGColor);
            rounded_path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y - (i+1)*(height + 2*unit), width, height) cornerRadius:unit];
            [rounded_path fill];
        }
    }
}


- (void)setBatteryLevel:(int)level
{
    m_BatteryLevel = level;
}

- (void)setBatteryCharging:(BOOL)charging
{
    if (charging != m_IsCharging)
    {
        m_IsCharging = charging;
        if (YES == m_IsCharging)
        {
            m_RedrawTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(redrawTimerFired) userInfo:nil repeats:YES];
        }
        else
        {
            [m_RedrawTimer invalidate];
            m_RedrawTimer = nil;
        }
    }
}

- (void)redrawTimerFired
{
    m_ChargingLevel++;
    if (m_ChargingLevel > 10)
    {
        m_ChargingLevel = 0;
    }
    [self setNeedsDisplay];
}

@end
