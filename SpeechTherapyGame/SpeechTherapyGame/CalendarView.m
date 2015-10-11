
#import "CalendarView.h"

@interface CalendarView()

// Gregorian calendar
@property (nonatomic, strong) NSCalendar *gregorian;

// Selected day
@property (nonatomic, strong) NSDate * selectedDate;

// Width in point of a day button
@property (nonatomic, assign) NSInteger dayWidth;

// Heigh in point of a day button
@property (nonatomic, assign) NSInteger dayHeigh;

// NSCalendarUnit for day, month, year and era.
@property (nonatomic, assign) NSCalendarUnit dayInfoUnits;

// Array of label of weekdays
@property (nonatomic, strong) NSArray * weekDayNames;

// View shake
@property (nonatomic, assign) NSInteger shakes;
@property (nonatomic, assign) NSInteger shakeDirection;

// Gesture recognizers
@property (nonatomic, strong) UISwipeGestureRecognizer * swipeleft;
@property (nonatomic, strong) UISwipeGestureRecognizer * swipeRight;



@end
@implementation CalendarView

#pragma mark - Init methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _dayWidth                   = frame.size.width/8;
        _dayHeigh                   = _dayWidth/2;
        _originX                    = (frame.size.width - 7*_dayWidth)/2;
        _gregorian                  = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        _borderWidth                = 4;
        _originY                    = _dayWidth;
        _calendarDate               = [NSDate date];
        _dayInfoUnits               = NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        
        _monthAndDayTextColor       = [UIColor brownColor];
        _dayBgColorWithoutData      = [UIColor whiteColor];
        _dayBgColorWithData         = [UIColor whiteColor];
        _dayBgColorSelected         = [UIColor brownColor];
        
        _dayTxtColorWithoutData     = [UIColor brownColor];;
        _dayTxtColorWithData        = [UIColor brownColor];
        _dayTxtColorSelected        = [UIColor whiteColor];
        
        _borderColor                = [UIColor brownColor];
        _allowsChangeMonthByDayTap  = NO;
        _allowsChangeMonthByButtons = NO;
        _allowsChangeMonthBySwipe   = YES;
        _hideMonthLabel             = NO;
        _keepSelDayWhenMonthChange  = NO;
        
        _nextMonthAnimation         = UIViewAnimationOptionTransitionCrossDissolve;
        _prevMonthAnimation         = UIViewAnimationOptionTransitionCrossDissolve;
        
        _defaultFont                = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        _titleFont                  = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
        
        
        _swipeleft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showNextMonth)];
        _swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:_swipeleft];
        _swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showPreviousMonth)];
        _swipeRight.direction=UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:_swipeRight];
        
        NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:[NSDate date]];
        components.hour         = 0;
        components.minute       = 0;
        components.second       = 0;
        
        _selectedDate = [_gregorian dateFromComponents:components];
        
        NSArray * shortWeekdaySymbols = [[[NSDateFormatter alloc] init] shortWeekdaySymbols];
        _weekDayNames  = @[shortWeekdaySymbols[1], shortWeekdaySymbols[2], shortWeekdaySymbols[3], shortWeekdaySymbols[4],
                           shortWeekdaySymbols[5], shortWeekdaySymbols[6], shortWeekdaySymbols[0]];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(id)init
{
    self = [self initWithFrame:CGRectMake(0, 0, 320, 400)];
    if (self)
    {
        
    }
    return self;
}

#pragma mark - Custom setters

-(void)setAllowsChangeMonthByButtons:(BOOL)allows
{
    _allowsChangeMonthByButtons = allows;
    [self setNeedsDisplay];
}

-(void)setAllowsChangeMonthBySwipe:(BOOL)allows
{
    _allowsChangeMonthBySwipe   = allows;
    _swipeleft.enabled          = allows;
    _swipeRight.enabled         = allows;
}

-(void)setHideMonthLabel:(BOOL)hideMonthLabel
{
    _hideMonthLabel = hideMonthLabel;
    [self setNeedsDisplay];
}

-(void)setSelectedDate:(NSDate *)selectedDate
{
    _selectedDate = selectedDate;
    [self setNeedsDisplay];
}

-(void)setCalendarDate:(NSDate *)calendarDate
{
    _calendarDate = calendarDate;
    [self setNeedsDisplay];
}


#pragma mark - Public methods

-(void)showNextMonth
{
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
    components.day = 1;
    components.month ++;
    NSDate * nextMonthDate =[_gregorian dateFromComponents:components];
    
    if ([self canSwipeToDate:nextMonthDate])
    {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        _calendarDate = nextMonthDate;
        components = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
        
        if (!_keepSelDayWhenMonthChange)
        {
            _selectedDate = [_gregorian dateFromComponents:components];
        }
        [self performViewAnimation:_nextMonthAnimation];
    }
    else
    {
        [self performViewNoSwipeAnimation];
    }
}


-(void)showPreviousMonth
{
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
    components.day = 1;
    components.month --;
    NSDate * prevMonthDate = [_gregorian dateFromComponents:components];
    
    if ([self canSwipeToDate:prevMonthDate])
    {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        _calendarDate = prevMonthDate;
        components = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
        
        if (!_keepSelDayWhenMonthChange)
        {
            _selectedDate = [_gregorian dateFromComponents:components];
        }
        [self performViewAnimation:_prevMonthAnimation];
    }
    else
    {
        [self performViewNoSwipeAnimation];
    }
}

#pragma mark - Various methods


-(NSInteger)buttonTagForDate:(NSDate *)date
{
    NSDateComponents * componentsDate       = [_gregorian components:_dayInfoUnits fromDate:date];
    NSDateComponents * componentsDateCal    = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
    
    if (componentsDate.month == componentsDateCal.month && componentsDate.year == componentsDateCal.year)
    {
        // Both dates are within the same month : buttonTag = day
        return componentsDate.day;
    }
    else
    {
        //  buttonTag = deltaMonth * 40 + day
        NSInteger offsetMonth =  (componentsDate.year - componentsDateCal.year)*12 + (componentsDate.month - componentsDateCal.month);
        return componentsDate.day + offsetMonth*40;
    }
}

-(BOOL)canSwipeToDate:(NSDate *)date
{
    if (_datasource == nil)
        return YES;
    return [_datasource canSwipeToDate:date];
}

-(void)performViewAnimation:(UIViewAnimationOptions)animation
{
    NSDateComponents * components = [_gregorian components:_dayInfoUnits fromDate:_selectedDate];
    
    NSDate *clickedDate = [_gregorian dateFromComponents:components];
    [_delegate dayChangedToDate:clickedDate];
    
    [UIView transitionWithView:self
                      duration:0.5f
                       options:animation
                    animations:^ { [self setNeedsDisplay]; }
                    completion:nil];
}

-(void)performViewNoSwipeAnimation
{
    _shakeDirection = 1;
    _shakes = 0;
    [self shakeView:self];
}

// Taken from http://github.com/kosyloa/PinPad
-(void)shakeView:(UIView *)theOneYouWannaShake
{
    [UIView animateWithDuration:0.05 animations:^
     {
         theOneYouWannaShake.transform = CGAffineTransformMakeTranslation(5*_shakeDirection, 0);
         
     } completion:^(BOOL finished)
     {
         if(_shakes >= 4)
         {
             theOneYouWannaShake.transform = CGAffineTransformIdentity;
             return;
         }
         _shakes++;
         _shakeDirection = _shakeDirection * -1;
         [self shakeView:theOneYouWannaShake];
     }];
}

#pragma mark - Button creation and configuration

-(UIButton *)dayButtonWithFrame:(CGRect)frame
{
    UIButton *button                = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font          = _defaultFont;
    button.frame                    = frame;
    button.layer.borderColor        = _borderColor.CGColor;
    [button     addTarget:self action:@selector(tappedDate:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

-(void)configureDayButton:(UIButton *)button withDate:(NSDate*)date
{
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:date];
    [button setTitle:[NSString stringWithFormat:@"%ld",(long)components.day] forState:UIControlStateNormal];
    button.tag = [self buttonTagForDate:date];
    
    if([_selectedDate compare:date] == NSOrderedSame)
    {
        // Selected button
        button.layer.borderWidth = 0;
        [button setTitleColor:_dayTxtColorSelected forState:UIControlStateNormal];
        [button setBackgroundColor:_dayBgColorSelected];
    }
    else
    {
        // Unselected button
        button.layer.borderWidth = _borderWidth/2.f;
        [button setTitleColor:_dayTxtColorWithoutData forState:UIControlStateNormal];
        [button setBackgroundColor:_dayBgColorWithoutData];
        
        if (_datasource != nil && [_datasource isDataForDate:date])
        {
            [button setTitleColor:_dayTxtColorWithData forState:UIControlStateNormal];
            [button setBackgroundColor:_dayBgColorWithData];
        }
    }

    /*
    NSDateComponents * componentsDateCal = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
    if (components.month != componentsDateCal.month)
        button.alpha = 0.6f;
     */
    
    NSDateComponents *weekDayComp = [_gregorian components:NSCalendarUnitWeekday fromDate:date];
    if (weekDayComp.weekday == 1) {
        [button setTitleColor:RGBCOLOR(217, 79, 79) forState:UIControlStateNormal];
    }
    
}

#pragma mark - Action methods

-(IBAction)tappedDate:(UIButton *)sender
{
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
    
    if (sender.tag < 0 || sender.tag >= 40)
    {
        // The day tapped is in another month than the one currently displayed
        
        if (!_allowsChangeMonthByDayTap)
            return;
        
        NSInteger offsetMonth   = (sender.tag < 0)?-1:1;
        NSInteger offsetTag     = (sender.tag < 0)?40:-40;
        
        // otherMonthDate set to beginning of the next/previous month
        components.day = 1;
        components.month += offsetMonth;
        NSDate * otherMonthDate =[_gregorian dateFromComponents:components];
        
        if ([self canSwipeToDate:otherMonthDate])
        {
            [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            _calendarDate = otherMonthDate;
            
            // New selected date set to the day tapped
            components.day = sender.tag + offsetTag;
            _selectedDate = [_gregorian dateFromComponents:components];

            UIViewAnimationOptions animation = (offsetMonth >0)?_nextMonthAnimation:_prevMonthAnimation;
            
            // Animate the transition
            [self performViewAnimation:animation];
        }
        else
        {
            [self performViewNoSwipeAnimation];
        }
        return;
    }
    
    // Day taped within the the displayed month
    NSDateComponents * componentsDateSel = [_gregorian components:_dayInfoUnits fromDate:_selectedDate];
    if(componentsDateSel.day != sender.tag || componentsDateSel.month != components.month || componentsDateSel.year != components.year)
    {
        // Let's keep a backup of the old selectedDay
        NSDate * oldSelectedDate = [_selectedDate copy];
        
        // We redifine the selected day
        componentsDateSel.day       = sender.tag;
        componentsDateSel.month     = components.month;
        componentsDateSel.year      = components.year;
        _selectedDate               = [_gregorian dateFromComponents:componentsDateSel];
        
        // Configure  the new selected day button
        [self configureDayButton:sender             withDate:_selectedDate];
        
        // Configure the previously selected button, if it's visible
        UIButton *previousSelected =(UIButton *) [self viewWithTag:[self buttonTagForDate:oldSelectedDate]];
        if (previousSelected)
            [self configureDayButton:previousSelected   withDate:oldSelectedDate];
        
        // Finally, notify the delegate
        [_delegate dayChangedToDate:_selectedDate];
    }
}


#pragma mark - Drawing methods

- (void)drawRect:(CGRect)rect
{
    NSDateComponents *components = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
    
    components.day = 1;
    NSDate *firstDayOfMonth         = [_gregorian dateFromComponents:components];
    NSDateComponents *comps         = [_gregorian components:NSWeekdayCalendarUnit fromDate:firstDayOfMonth];
    
    NSInteger weekdayBeginning      = [comps weekday];  // Starts at 1 on Sunday
    weekdayBeginning -=2;
    if(weekdayBeginning < 0)
        weekdayBeginning += 7;                          // Starts now at 0 on Monday
    
    NSRange days = [_gregorian rangeOfUnit:NSDayCalendarUnit
                                    inUnit:NSMonthCalendarUnit
                                   forDate:_calendarDate];
    
    NSInteger monthLength = days.length;
    NSInteger remainingDays = (monthLength + weekdayBeginning) % 7;
    
    
    // Frame drawing
    NSInteger minY = _originY + _dayWidth;
    NSInteger maxY = _originY + _dayWidth * (NSInteger)(1+(monthLength+weekdayBeginning)/7) + ((remainingDays !=0)? _dayWidth:0);
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(setHeightNeeded:)])
        [_delegate setHeightNeeded:maxY];
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, _borderColor.CGColor);
    CGContextAddRect(context, CGRectMake(_originX - _borderWidth/2.f, minY - _borderWidth/2.f, 7*_dayWidth + _borderWidth, _borderWidth));
    CGContextAddRect(context, CGRectMake(_originX - _borderWidth/2.f, maxY - _borderWidth/2.f, 7*_dayWidth + _borderWidth, _borderWidth));
    CGContextAddRect(context, CGRectMake(_originX - _borderWidth/2.f, minY - _borderWidth/2.f, _borderWidth, maxY - minY));
    CGContextAddRect(context, CGRectMake(_originX + 7*_dayWidth - _borderWidth/2.f, minY - _borderWidth/2.f, _borderWidth, maxY - minY));
    CGContextFillPath(context);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    // Top background
    UIView* topBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 110)];
    topBackground.layer.cornerRadius = 20;
    topBackground.backgroundColor = RGBCOLOR(52, 152, 219);
    [self addSubview:topBackground];
    
    // Top background
    UIView* bottomBackground = [[UIView alloc] initWithFrame:CGRectMake(0, topBackground.y + topBackground.height + 10, self.width, 552)];
    bottomBackground.layer.cornerRadius = 20;
    bottomBackground.backgroundColor = RGBCOLOR(52, 152, 219);
    [self addSubview:bottomBackground];
    
    UIImageView* elephant = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"elephant"]];
    elephant.frame = CGRectMake(591-60, 72-47, 247, 221);
    [self addSubview:elephant];
    
    // Played information
    UILabel *timePlayed              = [[UILabel alloc]initWithFrame:CGRectMake(44, bottomBackground.y + 30, self.bounds.size.width - 2*44, 40)];
    timePlayed.textAlignment         = NSTextAlignmentLeft;
    timePlayed.text                  = @"Played: 20 hours 30 minutes";
    timePlayed.font                  = [UIFont fontWithName:@"Marker Felt" size:35];
    timePlayed.textColor             = _monthAndDayTextColor;
    [self addSubview:timePlayed];
    UILabel *collectedStar              = [[UILabel alloc]initWithFrame:CGRectMake(44, timePlayed.y + timePlayed.height + 10, self.bounds.size.width - 2*44, 40)];
    collectedStar.textAlignment         = NSTextAlignmentLeft;
    collectedStar.text                  = @"Collected: 6";
    collectedStar.font                  = [UIFont fontWithName:@"Marker Felt" size:35];
    collectedStar.textColor             = _monthAndDayTextColor;
    [self addSubview:collectedStar];
    
    // Month label
    NSDateFormatter *format         = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMMM yyyy"];
    NSString *dateString            = [[format stringFromDate:_calendarDate] capitalizedString];
    
    if (!_hideMonthLabel)
    {
        UILabel *titleText              = [[UILabel alloc]initWithFrame:CGRectMake(44, 0, self.bounds.size.width - 2*44, topBackground.height)];
        titleText.textAlignment         = NSTextAlignmentLeft;
        titleText.text                  = dateString;
        titleText.font                  = [UIFont fontWithName:@"ChalkboardSE-Bold" size:54];
        titleText.textColor             = _monthAndDayTextColor;
        [self addSubview:titleText];
        NSMutableAttributedString *text =
        [[NSMutableAttributedString alloc]
         initWithAttributedString: titleText.attributedText];
        
        [text addAttribute:NSForegroundColorAttributeName
                     value:RGBCOLOR(241, 196, 15)
                     range:NSMakeRange([dateString rangeOfString:@" "].location + 1, 4)];
        [titleText setAttributedText: text];
    }
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(setMonthLabel:)])
        [_delegate setMonthLabel:dateString];
    
    
    _originY = 112 + 150;
    NSInteger leftPadding = 15;
    // Day labels
    __block CGRect frameWeekLabel = CGRectMake(0, _originY , _dayWidth, _dayHeigh);
    [_weekDayNames  enumerateObjectsUsingBlock:^(NSString * dayOfWeekString, NSUInteger idx, BOOL *stop)
     {
         frameWeekLabel.origin.x         = leftPadding + (_dayWidth*idx);
         UILabel *weekNameLabel          = [[UILabel alloc] initWithFrame:frameWeekLabel];
         weekNameLabel.text              = dayOfWeekString;
         weekNameLabel.textColor         = idx == 6 ? RGBCOLOR(217, 79, 79) : _monthAndDayTextColor;
         weekNameLabel.font              = [UIFont fontWithName:@"Marker Felt" size:29];
         weekNameLabel.backgroundColor   = [UIColor clearColor];
         weekNameLabel.textAlignment     = NSTextAlignmentCenter;
         [self addSubview:weekNameLabel];
     }];
    
    // Current month
    NSDateComponents *regularComp = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday |NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSArray* achievementDays = [[NSUserDefaults standardUserDefaults] arrayForKey:kAchievementDays];
    for (NSInteger i= 0; i<monthLength; i++)
    {
        components.day      = i+1;
        NSInteger offsetX   = (_dayWidth*((i+weekdayBeginning)%7));
        NSInteger offsetY   = (_dayHeigh *((i+weekdayBeginning)/7));
        UIButton *button    = [self dayButtonWithFrame:CGRectMake(leftPadding + offsetX, _originY+_dayHeigh+offsetY, _dayWidth, _dayHeigh)];
        NSDate* date = [_gregorian dateFromComponents:components];
        [self configureDayButton:button withDate:date];
        [self addSubview:button];
        
        for (NSDate* d in achievementDays) {
            
             NSDateComponents *comp1 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:d];
            NSDateComponents *comp2 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
            
            if (comp1.day == comp2.day && comp1.month == comp2.month && comp1.year == comp2.year) {
                UIImageView* star = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star-icon"]];
                star.width = 16;
                star.height = 15;
                star.x = button.width-40;
                star.y = button.height-20;
                [button addSubview:star];
            }
        }
        
        if (components.day == regularComp.day && components.month == regularComp.month) {
            UIView* todayCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
            todayCircle.layer.cornerRadius = todayCircle.width/2;
            todayCircle.backgroundColor = RGBCOLOR(217, 79, 79);
            todayCircle.center = button.center;
            [self insertSubview:todayCircle belowSubview:button];
            // Change color of today is Sunday
            if (regularComp.weekday == 1) {
                [button setTitleColor:RGBCOLOR(255, 255, 255) forState:UIControlStateNormal];
            }
        }
    }
    
    
    /*
    // Previous month
    NSDateComponents *previousMonthComponents = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
    previousMonthComponents.month --;
    NSDate *previousMonthDate = [_gregorian dateFromComponents:previousMonthComponents];
    NSRange previousMonthDays = [_gregorian rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:previousMonthDate];
    NSInteger maxDate = previousMonthDays.length - weekdayBeginning;
    for (int i=0; i<weekdayBeginning; i++)
    {
        previousMonthComponents.day     = maxDate+i+1;
        NSInteger offsetX               = (_dayWidth*(i%7));
        NSInteger offsetY               = (_dayHeigh *(i/7));
        UIButton *button                = [self dayButtonWithFrame:CGRectMake(leftPadding + offsetX, _originY + _dayHeigh + offsetY, _dayWidth, _dayHeigh)];

        [self configureDayButton:button withDate:[_gregorian dateFromComponents:previousMonthComponents]];
        [self addSubview:button];
    }
    
    // Next month
    if(remainingDays == 0)
        return ;
    
    NSDateComponents *nextMonthComponents = [_gregorian components:_dayInfoUnits fromDate:_calendarDate];
    nextMonthComponents.month ++;
    
    for (NSInteger i=remainingDays; i<7; i++)
    {
        nextMonthComponents.day         = (i+1)-remainingDays;
        NSInteger offsetX               = (_dayWidth*((i) %7));
        NSInteger offsetY               = (_dayHeigh *((monthLength+weekdayBeginning)/7));
        UIButton *button                = [self dayButtonWithFrame:CGRectMake(leftPadding + offsetX, _originY + _dayHeigh + offsetY, _dayWidth, _dayHeigh)];

        [self configureDayButton:button withDate:[_gregorian dateFromComponents:nextMonthComponents]];
        [self addSubview:button];
    }
     */
}

@end
