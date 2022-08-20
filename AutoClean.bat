@echo off
setlocal EnableDelayedExpansion
set workDir="E:\test\AutoClean"
cd /D "%workDir:"=%"
REM            1  2  3  4  5  6  7  8  9  10  11  12
set tmpList=0 31 29 31 30 31 30 31 31 30  31  30  31
set monthDays[0]=0
set /a count=0
for %%i in (%tmpList%) do (
    set monthDays[!count!]=%%i
    set /a count+=1
)
REM  至此，monthDays数组存储了每个月份的天数


set /a year=%1
set /a month=%2
set /a day=%3
set /a dayAgo=%4

call:DateOfDaysAgo year month day dayAgo newYear newMonth newDay
echo %newYear% %newMonth% %newDay%


goto:eof

for /f "tokens=1,2" %%1 in ('date /T') do (
	set curDate=%%1
)

for /f %%1 in ('time /T') do (
	set curTime=%%1
)
echo %curDate% %curTime%

call:ParseDate curDate curYear curMonth curDay
call:ParseTime curTime curHour curMinute


set tempYear=""
set tempMonth=""
set tempDay=""
set tempHour=""
set tempMinute=""

for /f "tokens=1,2,3,* delims= " %%1 in ('dir /OD') do (
	set tempDate=%%1
	set tempTime=%%2
	call:ParseDate tempDate tempYear tempMonth tempDay
	if not !tempYear! EQU 3000 (
		if not "%%4" == "." (
			if not "%%4" == ".." (
				call:ParseTime tempTime tempHour tempMinute
				echo %%4
			)
		)
	)
)




goto:eof


REM 函数功能：获取输入日期几天前的日期
REM 入参1：【输入】变量名，表示输入的年份
REM 入参2：【输入】变量名，表示输入的月份
REM 入参3：【输入】变量名，表示输入的日
REM 入参4：【输入】变量名，天数，表示希望获取x天之前的日期 1 <= x <= 10
REM 入参5：【输出】变量名，表示得到的年份
REM 入参6：【输出】变量名，表示得到的月份
REM 入参7：【输出】变量名，表示得到的日


:DateOfDaysAgo
set /a inputYearA=!%1!
set /a inputMonthA=!%2!
set /a inputDayA=!%3!
set /a daysAgoA=!%4!
REM 如果欲减掉天数小于日期
if !daysAgoA! LSS !inputDayA! (
    set /a %5=inputYearA
    set /a %6=inputMonthA
    set /a %7=inputDayA - daysAgoA
    goto:eof
)
REM 如果是一月，那减掉几天就变成了前一年的12月
if !inputMonthA! EQU 1 (
    set /a %5=inputYearA-1
    set /a %6=12
    set /a %7=inputDayA + 31 - daysAgoA
    goto:eof 
)
REM 如果是三月，那需要查询是否是闰年
if !inputMonthA! EQU 3 (
    set /a %5=inputYearA
    set /a %6=2
    call:JudgeRunYear inputYearA bRunYear
    if "!bRunYear!" == "true" (
        set /a %7=inputDayA + 29 - daysAgoA
    ) else (
        set /a %7=inputDayA + 28 - daysAgoA
    )
    goto:eof 
)
REM 其他情况
set /a %5=inputYearA
set /a %6=inputMonthA-1
set /a tmpIndex=inputMonthA-1
set /a %7=inputDayA + monthDays[%tmpIndex%] - daysAgoA
goto:eof


REM 函数功能：判断闰年
REM 入参1：【输入】变量名，表示输入的年份
REM 入参2：【输出】变量名，表示是否是闰年，是则为true，否则false
:JudgeRunYear
set /a yearB=!%1!
set /a remain100=yearB %% 100
if !remain100!  EQU 0 (
    set /a remain400=yearB %% 400
    if !remain400! EQU 0 (
        set %2=true
        goto:eof
    )
    set %2=false
    goto:eof
)
set /a remain4=yearB %% 4
if !remain4! EQU 0 (
    set %2=true
) else (
    set %2=false
)
goto:eof





REM  日期比较（相较于当前日期）
:DateTimeCmp
set yearC=!%1!
set monthC=!%2!
set dayC=!%3!
set hourC=!%4!
set minuteC=!%5!

if %yearC% LSS %curYear% (
	goto LESS
) else if %yearC% GTR %curYear% (
	goto BIGGER
)

if %monthC% LSS %curMonth% (
	goto LESS
) else if %monthC% GTR %curMonth% (
	goto BIGGER
)

if %dayC% LSS %curDay% (
	goto LESS
) else if %dayC% GTR %curDay% (
	goto BIGGER
)

if %hourC% LSS %curHour% (
	goto LESS
) else if %hourC% GTR %curHour% (
	goto BIGGER
)

if %minuteC% LSS %curMinute% (
	goto LESS
) else if %minuteC% GTR %curMinute% (
	goto BIGGER
)

set /a %6=0
goto:eof

:LESS
set /a %6=-1
goto:eof

:BIGGER
set /a %6=1
goto:eof


:ParseTime


set strD=!%1:"=!
call:StrLen strD lenD

if %lenD% NEQ 5 (
	goto NotATime
)

if not "%strD:~2,1%" == ":" (
	goto NotATime
)

set hourD=%strD:~0,2%
call:IsNumber hourD bNumE
echo hourD %hourD%
if not "%bNumE%" == "true" (
	goto NotATime
)
if %hourD:~0,1% EQU 0 (
	set hourD=%hourD:~1%
)
set /a %2=hourD

set minuteD=%strD:~3,2%
call:IsNumber minuteD bNumE
if not "%bNumE%" == "true" (
	goto NotATime
)
if %minuteD:~0,1% EQU 0 (
	set minuteD=%minuteD:~1%
)
set /a %3=minuteD
goto:eof

REM if not a date, set the year to 3000
:NotATime
set /a %2=25
goto:eof



:ParseDate


set strE=!%1:"=!

call:StrLen strE lenE

if %lenE% NEQ 10 (
	goto NotADate
)

if not "%strE:~4,1%" == "/" (
	goto NotADate
)

if not "%strE:~7,1%" == "/" (
	goto NotADate
)

set yearE=%strE:~0,4%
call:IsNumber yearE bNumE
if not "%bNumE%" == "true" (
	goto NotADate
)
set /a %2=yearE

set monthE=%strE:~5,2%
call:IsNumber monthE bNumE
if not "%bNumE%" == "true" (
	goto NotADate
)
if %monthE:~0,1% EQU 0 (
	set monthE=%monthE:~1%
)
set /a %3=monthE

set dayE=%strE:~8,2%
call:IsNumber dayE bNumE
if not "%bNumE%" == "true" (
	goto NotADate
)
if %dayE:~0,1% EQU 0 (
	set dayE=%dayE:~1%
)
set /a %4=dayE
goto:eof

REM if not a date, set the year to 3000
:NotADate
set /a %2=3000
goto:eof



REM verified
:IsNumber
set strF=!%1!
for %%i in (0 1 2 3 4 5 6 7 8 9) do (
	if "!strF!" == "" (
		set %2=true
		goto:eof
	)
	set strF=!strF:%%i=!
)
if "!strF!" == "" (
	set %2=true
) else (
	set %2=false
)
goto:eof

REM   verified
:StrLen
set strG=!%1:"=!
set /a countG=0
:loopG

if not "!strG:~%countG%,1!" == "" (
	set /a countG+=1
	goto loopG
)

set /a %2=countG
goto:eof