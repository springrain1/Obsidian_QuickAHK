SetTitleMatchMode, Regex ;正则表达式
;经大佬@梦醒(FeiYue)指点，Tang2022-02-18整理，Springrain2022-02-19拓展用法3、4和5，Springrain2022-03-20拓展用法6，Springrain2022-06-11合并Memos_AHK，并参考天大仝的quickCapture AHK优化代码
;功能：当按下Win+1，若0.5秒内剪贴板内容发生变化，则任意界面调用黑曜石Obsidian全局查询（以剪贴板内容为查询关键词），否则仅仅只启动/激活Ob窗口
;使用场景
;1.任意界面划选文本内容，按下按下Win+1，即可调用Ob全局检索（比如有时候在word、excel、浏览器或任意可复制文本内容的地方，想看下这个关键词，ob里有没有收录相关资料）。
;2.当未选中/划选文本时，只启动或激活指定的Ob窗口，一键两用。当存在两个或以上的Ob库时，切换尤为快捷。
;3.实现添加网页或其它任何地方的内容摘录到当天的每日日记中，加入时间戳，使其在memos中呈现
;4.实现在任何地方启动弹窗，输入标题名称新建页面，将内容发送到ob
;5.其它小功能优化
;6.实现在XMind 8 Update 9、XMind2022、WorkFlowy和Thebrain中，自动创建OB双链，Thebrain可以ctrl+alt+z键根据节点内容选择创建，其它为选中内容后，alt+z创建。值得注意的是需要关闭XMind2022后，才可在WorkFlowy中，自动创建OB双链
;7. 合并Memos_AHK和quickCapture AHK功能：支持不开OB，将内容补充到对应的每日日记文件中

;------初始化配置------;
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance,Force
FileEncoding, UTF-8-RAW
;FileEncoding, UTF-8

if (FileExist(".\Obsidian_QuickAHK_Config.ini")) {
    IniRead, Vault1, .\Obsidian_QuickAHK_Config.ini, settings, Vault1
	IniRead, Vault2, .\Obsidian_QuickAHK_Config.ini, settings, Vault2
	IniRead, JournalsFileFolder, .\Obsidian_QuickAHK_Config.ini, settings, JournalsFileFolder
	IniRead, PagesFileFolder, .\Obsidian_QuickAHK_Config.ini, settings, PagesFileFolder
	IniRead, TemplateFile, .\Obsidian_QuickAHK_Config.ini, settings, TemplateFile
	IniRead, Memos_Process, .\Obsidian_QuickAHK_Config.ini, settings, Memos_Process
	IniRead, Memos_Time, .\Obsidian_QuickAHK_Config.ini, settings, Memos_Time
}

If (Vault1 = "" OR Vault1 = "ERROR") {
	InputBox, Vault1, 请输入Obsidian库名1, please set folder for vault1 content
	InputBox, Vault2, 请输入Obsidian库名2, please set folder for vault2 content
	InputBox, JournalsFileFolder, 请配置日记存放文件夹路径, please set folder for journals content
	InputBox, PagesFileFolder, 请主题笔记存放文件夹路径, please set folder for pages content
	InputBox, TemplateFile, 请配置日记模板的文件路径, please set file for journals templatefile content
	InputBox, Memos_Process, 请配置Memos解析指定标题后memo, please set process_memo for Memos
	InputBox, Memos_Time, 请配置Memos解析指定标题后memo, please set memos_time for Memos
	IniWrite, %Vault1%, .\Obsidian_QuickAHK_Config.ini, settings, Vault1
	IniWrite, %Vault2%, .\Obsidian_QuickAHK_Config.ini, settings, Vault2
	IniWrite, %JournalsFileFolder%, .\Obsidian_QuickAHK_Config.ini, settings, JournalsFileFolder
	IniWrite, %PagesFileFolder%, .\Obsidian_QuickAHK_Config.ini, settings, PagesFileFolder
	IniWrite, %TemplateFile%, .\Obsidian_QuickAHK_Config.ini, settings, TemplateFile
	IniWrite, %Memos_Process%, .\Obsidian_QuickAHK_Config.ini, settings, Memos_Process
	IniWrite, %Memos_Time%, .\Obsidian_QuickAHK_Config.ini, settings, Memos_Time
}
;------初始化配置------;

$#q::
Loop
	Clipboard:=""
Until (Clipboard="")
Send ^c{Ctrl Up}
ClipWait, 0.5
	if (ErrorLevel=0)
	{
		;~ MsgBox Control-C copied the following contents to the clipboard:`n`n%clipboard%
		FormatTime, FileName, A_Now, yyyy_MM_dd
		FormatTime, TimeString, A_Now, HH:mm
		JournalsPathname = %JournalsFileFolder%%FileName%.md
		笔记内容0 := FileOpen(JournalsPathname, "r").Read()
		if  (笔记内容0 = "")
		{
			模板内容 := FileOpen(TemplateFile, "r").Read()
			FileOpen(JournalsPathname, "w").Write(模板内容) ;保存模板内容
		}
		;~ MsgBox The specified date and time, when formatted, is %TimeString%.
		StringReplace, clipboard, clipboard, `r`n, <br> , All
		StringReplace, clipboard, clipboard, `n, <br> , All
		;~ MsgBox, % clipboard
		FileAppend, `n- %TimeString% %clipboard%, %JournalsFileFolder%%FileName%.md
		MsgBox, 0, , 保存成功, 0.5
	}
return

;filetype := "%A_YYYY%_%A_MM%_%A_DD%.md"
;JournalsPathname = %JournalsFileFolder%%filetype%
;-------------------------Memos_AHK-----------------------------
运行日期 := A_DD
读取说明文件:
	FormatTime, FileName, A_Now, yyyy_MM_dd
	JournalsPathname = %JournalsFileFolder%%FileName%.md
	插入文件路径1 := 原义字符转义(JournalsPathname)
    插入模板路径1 := 原义字符转义(TemplateFile)
    插入文件位置1 := 原义字符转义(Memos_Process)
    插入前置内容1 := 原义字符转义(Memos_Time)
return

$#j:: ; 为菜单栏创建子菜单:
    if WinExist("随笔感悟-ahk")
    {
        msgbox 0,随笔提示, 已经打开随笔框, 2
        return
    }

    ;检测日期已经变化，运行初始程序，重新确定文件名
    if (运行日期 != A_DD)
        gosub 读取说明文件
    gosub Suibi
return

#IfWinActive 随笔感悟-ahk ;分配快捷键
    !w::Goto SaveCurrentFile
!q::
    Gui, Destroy
    MsgBox, 0, , 取消, 0.3
return
#IfWinActive

Suibi:
    gui, font, s15, Verdana
    yearss :=Substr(A_YYYY,3)
    Gui, +Resize ; 让用户可以调整窗口的大小.
    Gui, Add, Edit, vMainEdit WantTab W770 R20
    Gui, Show,, 随笔感悟-ahk
    CurrentFileName = %文件保存路径%\%A_YYYY%_%A_MM%_%A_DD%.md ; 表示当前没有文件.
    笔记内容0 := FileOpen(插入文件路径1, "r").Read()
    if  (笔记内容0 = "")
    {
        模板内容 := FileOpen(插入模板路径1, "r").Read()
        ;新模板内容 := %top_content%%模板内容% ;内容格式拼接，日期计算函数未找到
        FileOpen(插入文件路径1, "w").Write(模板内容) ;保存模板内容
    }
return

SaveCurrentFile: ; 追加文件保存
    GuiControlGet, MainEdit ; 获取编辑控件的内容.
    笔记内容 := FileOpen(插入文件路径1, "r").Read()
    ;在特定位置插入内容
    StringReplace, MainEdit1,MainEdit,`n,<br>, UseErrorLevel ;替换换行内容
    
    新笔记内容 := strreplace(笔记内容,插入文件位置1,插入文件位置1 . 插入前置内容1 . MainEdit1)
    FileOpen(插入文件路径1, "w").Write(新笔记内容) ;保存新内容
    Gui, Destroy
return

GuiSize:
    if (ErrorLevel = 1) ; 窗口被最小化了. 无需进行操作.
        return
    ; 否则, 窗口的大小被调整过或被最大化了. 调整编辑控件的大小以匹配窗口.
    NewWidth := A_GuiWidth - 20
    NewHeight := A_GuiHeight - 20
    GuiControl, Move, MainEdit, W%NewWidth% H%NewHeight%
return
FileExit: ; 用户在 File 菜单中选择了 "Exit".
GuiClose: ; 用户关闭了窗口.
Save: ;Save标签，保存按键
    Goto SaveCurrentFile
return
Abolish:
    Gui, Destroy
    MsgBox, 0, , 取消, 0.3
return

原义字符转义(x)
{
    ;原义字符串转义成正常字符串。不知道有没有命令，感觉很愚蠢。换行算一个字符，时和分算2个，日期和秒还没加上。
    a := ""
    for index, 内容块 in strsplit(x,"``n")
        a := a . 内容块 . "`n"
    x := substr(a, 1,-1)

    a := ""
    for index, 内容块 in strsplit(x,"%A_SPACE%")
        a := a . 内容块 . A_SPACE
    x := substr(a, 1,-1)

    a := ""
    for index, 内容块 in strsplit(x,"%A_Min%")
        a := a . 内容块 . A_Min
    x := substr(a, 1,-2)

    a := ""
    for index, 内容块 in strsplit(x,"%A_Hour%")
        a := a . 内容块 . A_Hour
    x := substr(a, 1,-2)

    a := "" ;A_DD，2位数表示的当前月份日期(01-31)
    for index, 内容块 in strsplit(x,"%A_DD%")
        a := a . 内容块 . A_DD
    x := substr(a, 1,-2)

    a := "" ;A_MM, 2 位数表示的当前月份(01-12). 与 A_Mon 含义相同.
    for index, 内容块 in strsplit(x,"%A_MM%")
        a := a . 内容块 . A_MM
    x := substr(a, 1,-2)

    a := "" ;A_YYYY, 4 位数表示的当前年份(例如 2004). 与 A_Year 含义相同
    for index, 内容块 in strsplit(x,"%A_YYYY%")
        a := a . 内容块 . A_YYYY
    x := substr(a, 1,-4)

    a := "" ;当前的年份和周数(例如200453)
    if instr(x,"%A_YWeek%")
    {
        ; for index, 内容块 in strsplit(x,"%A_YWeek%")
        ;     a := a . 内容块 . A_YWeek
        x := strreplace(x,"%A_YWeek%",substr(A_YWeek,5))
    }

    a := "" ;A_WDay 1 位数表示的当前星期经过的天数(1-7). 在所有区域设置中 1 都表示星期天.
    星期 := A_WDay - 1
    ; if (星期 = 0)
    ;     星期 := 7
    for index, 内容块 in strsplit(x,"%A_WDay%")
        a := a . 内容块 . 星期
    x := substr(a, 1,-1)

    a := "" ;A_Sec 2 位数表示的当前秒数(00-59).
    for index, 内容块 in strsplit(x,"%A_Sec%")
        a := a . 内容块 . A_Sec
    x := substr(a, 1,-2)

return x
}
;--------------------------------------------------------------------------------------------------------

$#1::		;任意界面调用黑曜石Obsidian查询，或启动/激活其窗口
Loop
	Clipboard:=""
Until (Clipboard="")
Send ^c{Ctrl Up}
ClipWait, 0.5
	if (ErrorLevel=0)
	{
		Text = %Clipboard%
		Text := RegExReplace(Text, "s)^\s+|\s+$", "")
		Text := RegExReplace(Text, "m)^[ `t]+|[ `t]+$", "")
		Clipboard := Text
		Run obsidian://open?vault=%Vault1%,,max
		Sleep 300
		Sendinput,!f		;请修改成Ob全局检索的实际热键
		Sleep 200
		Sendinput,^v
		WinMaximize, A
	}
	else
	{
		Run obsidian://open?vault=%Vault1%,,max
		Sleep 200
		WinMaximize, A
	}
return

$#2::		;任意界面调用黑曜石Obsidian查询，或启动/激活其窗口
Loop
	Clipboard:=""
Until (Clipboard="")
Send ^c{Ctrl Up}
ClipWait, 0.5
	if (ErrorLevel=0)
	{
		Text = %Clipboard%
		Text := RegExReplace(Text, "s)^\s+|\s+$", "")
		Text := RegExReplace(Text, "m)^[ `t]+|[ `t]+$", "")
		Clipboard := Text
		Run obsidian://open?vault=%Vault2%,,max
		Sleep 300
		Sendinput,!f		;请修改成Ob全局检索的实际热键
		Sleep 200
		Sendinput,^v
		WinMaximize, A
	}
	else
	{
		Run obsidian://open?vault=%Vault2%,,max
		Sleep 200
		WinMaximize, A
	}
return

$#3::	 ;实现在每日日记中添加网页或其它地方的内容摘录
Loop
	Clipboard:=""
	Until (Clipboard="")
	Send ^c{Ctrl Up}
	ClipWait, 0.5
	if (ErrorLevel=0)
	{
		Loop
		{
			StringReplace, clipboard,clipboard, `r`n,"<br>", UseErrorLevel
			if (ErrorLevel=0) ;全部替换完，退出循环
				break
		}
		
		Loop
		{
			StringReplace, clipboard,clipboard, %A_SPACE%%A_SPACE%, %A_SPACE%, UseErrorLevel;替换两个空格为一个空格
			if (ErrorLevel=0)
				break
		}

		a := "- "
		b = %A_Hour%:%A_Min%
		c := " "
		d = %Clipboard% ;获取剪贴板内容
		content_markdown = %a%%b%%c%%d% ;内容格式拼接
		card_title = %A_YYYY%_%A_MM%_%A_DD%
		run obsidian://advanced-uri?vault=%Vault1%&filepath=journals/%card_title%.md&mode=append&data=%content_markdown% ;Obsidian_data为库文件名，使用需要修改为自己的名称，pages为库中的某一文件夹名，支持多层级目录，使用“/”
	}
return

$#4::	 ;实现新建页面，将内容发送到其中
	content_markdown = %Clipboard% ;获取剪贴板内容
	inputbox card_title,请输出标题
	if (ErrorLevel=0)
	{
		Process, Exist, Obsidian.exe ;是否打开了obsidian进程？
		NewPID = %ErrorLevel%  ; 由于 ErrorLevel 会经常发生改变, 所以要立即保存这个值.
		run obsidian://advanced-uri?vault=%Vault1%&filepath=pages/%card_title%.md&mode=append ;Obsidian_data为库文件名，使用需要修改为自己的名称，pages为库中的某一文件夹名，支持多层级目录，使用“/”
		if  NewPID = 0
			Sleep 5000 ;延迟5s等待obsidian打开
		else
			Sleep 500
		Sendinput,^v ;代替手动粘贴内容
	}
return


#IfWinActive ahk_class SWT_Window0
;; 下面的语句块只在XMind 8 Update 9中生效，创建OB双链
	!z::
	Loop
		Clipboard:=""
		Until (Clipboard="")
		Send ^c{Ctrl Up}
		ClipWait, 0.5
		if (ErrorLevel=0)
		{
			top_content1 := "obsidian://advanced-uri?vault="
			top_content2 := "&filepath=pages%252F" 
			card_title = %Clipboard% ;获取剪贴板内容
			end_content := ".md"
			Text = %top_content1%%Vault1%%top_content2%%card_title%%end_content%
			Clipboard := Text
			Sendinput, {Esc}
			Sleep 100
			Sendinput,^h
			Sleep 100
			Sendinput,^v
			Sleep 100
			Send {enter}
		}
return
#IfWinActive

#IfWinActive ahk_class Chrome_WidgetWin_1 ;; 下面的语句块只在对应软件中生效，创建OB双链，发现OB、XMind2022、WorkFlowy都是此类class
	!z::
		Loop
		Clipboard:=""
		Until (Clipboard="")
		Send ^c{Ctrl Up}
		ClipWait, 0.5
		if (ErrorLevel=0)
		{
			top_content1 := "obsidian://advanced-uri?vault="
			top_content2 := "&filepath=pages%252F" 
			card_title = %Clipboard% ;获取剪贴板内容
			end_content := ".md"
			Text = %top_content1%%Vault1%%top_content2%%card_title%%end_content%
			Clipboard := Text
			if WinExist("ahk_exe XMind.exe") ;实现在XMind2022中创建OB链接，XMind和WorkFlowy只能打开其一
			{
				Sendinput, {Esc}
				Sleep 100
				Sendinput,^k
				Sleep 100
				Sendinput,^a
				Sleep 100
				Sendinput,^v ;代替手动粘贴链接
				Sleep 100
				Send {enter}
			}
			else  ;实现在WorkFlowy中创建OB链接"ahk_exe WorkFlowy.exe"(幕布网页版本不支持，自动加入了前缀http://)
			{
				Sendinput,^k
				Sleep 200
				Sendinput,^v ;代替手动粘贴链接
				Sleep 200
				Send {enter}
			}
		}
return
#IfWinActive

#IfWinActive ahk_class HwndWrapper* ; [TheBrain.exe;;5b9079cd-76da-44f3-a85c-eb1be5019fb0] ; 需要正则表达式查找
;; 下面的语句块只在Thebrain中生效，创建Logseq & OB双链
	!z::
		Loop
		Clipboard:=""
		Until (Clipboard="")
		Send !+1 ;复制为大纲
		Sleep 500
		if (ErrorLevel=0)
		{
			Loop
			{
				StringReplace, clipboard, clipboard, `r`n, , All
				if (ErrorLevel=0) ;全部替换完，退出循环
					break
			}
			if WinExist("ahk_exe Logseq.exe") ;实现Thebrain添加链接方式的选择：如果Logseq已经打开则使用logseq的url，否则为obsidian的url
			{
				top_content     := "logseq://graph/"
				centre_content := "?page="
				card_title = %Clipboard% ;获取剪贴板内容
				Text = %top_content%%Vault1%%centre_content%%card_title%
			}
			else
			{
				top_content1 := "obsidian://advanced-uri?vault="
				top_content2 := "&filepath=pages%252F"
				card_title = %Clipboard% ;获取剪贴板内容
				end_content := ".md"
				Text = %top_content1%%Vault1%%top_content2%%card_title%%end_content%
			}
			Clipboard := Text
			Sleep 300
			Sendinput,!+v ;粘贴链接到项目（想法）上
			Sleep 300
			
			Loop
			Clipboard:=""
			Until (Clipboard="")
			Sendinput,!c ;复制想法的本地路径
			Sleep 500
			if (ErrorLevel=0)
			{
				TB_Link = %Clipboard% ;获取剪贴板内容
				top_Link_add := "[toTB]("
				end_Link_add := ")"
				toTB_Link = %top_Link_add%%TB_Link%%end_Link_add%
				FileAppend, > %toTB_Link%`n, %PagesFileFolder%%card_title%.md
				MsgBox, 0, , 操作成功, 0.5
			}
		}
	return

	^!z::
		Loop
		Clipboard:=""
		Until (Clipboard="")
		Send ^c{Ctrl Up}
		ClipWait, 0.5
		if (ErrorLevel=0)
		{
			if WinExist("ahk_exe Logseq.exe") ;实现Thebrain添加链接方式的选择：如果Logseq已经打开则使用logseq的url，否则为obsidian的url
			{
				top_content     := "logseq://graph/"
				centre_content := "?page="
				card_title = %Clipboard% ;获取剪贴板内容
				Text = %top_content%%Vault1%%centre_content%%card_title%
			}
			else
			{
				top_content1 := "obsidian://advanced-uri?vault="
				top_content2 := "&filepath=pages%252F"
				card_title = %Clipboard% ;获取剪贴板内容
				end_content := ".md"
				Text = %top_content1%%Vault1%%top_content2%%card_title%%end_content%
			}
			Clipboard := Text
			Sendinput, {Esc}
			Sleep 300
			Sendinput,!+v
			Sleep 300
			
			Loop
			Clipboard:=""
			Until (Clipboard="")
			Sendinput,!c ;复制想法的本地路径
			Sleep 500
			if (ErrorLevel=0)
			{
				TB_Link = %Clipboard% ;获取剪贴板内容
				top_Link_add := "[toTB]("
				end_Link_add := ")"
				toTB_Link = %top_Link_add%%TB_Link%%end_Link_add%
				FileAppend, > %toTB_Link%`n, %PagesFileFolder%%card_title%.md
				MsgBox, 0, , 操作成功, 0.5
			}
		}
	return
#IfWinActive

;F1窗口置顶
F1::Winset,Alwaysontop,TOGGLE, A
;---------------------------------------------------------------------
;映射一个动作——最小化当前窗口
#w::    ;;这里的 #->表示window键  w->表示字母w键                   
WinMinimize,A    ;;最小化当前窗口      
return     ;;结束代码段
;----------------------------------------------------------------------
;映射一个键——上左下右，映射成了 alt+h,j,k,l (符合vim风格)
!k::   ;; !->alt键   k->字母键k
Send {Up}   ;;输入 上 键
return

!j::
Send {Down}
return

!h::
Send {Left}
return

!l::
Send {Right}
return
;----------------------------------------------------------------------
;映射一组键盘操作——删除复制粘贴一整行
;;;;;;;;;;;;;删除一整行
!d::   ;alt+d
Send {Home}   ;输出回车
Send +{End}   ;输入shitf键+end键
Send {delete}   ;输入delete键
return 
;;;;;;;;;;;;;复制一整行
!y::	;alt+y
send {home}
send +{end}
send ^c   ;输出ctrl+c,复制一整行
return
;;;;;;;;;;;;;另起一行粘贴内容                                                                   
!p::	;alt+p                                                                                        
send {end}                                                                                  
send {enter}                                                                                
send %clipboard%    ;将剪贴板的内容输出                                                  
return  
;----------------------------------------------------------------------
#IfWinActive ahk_class CabinetWClass
	^+c::   ;ctrl+shift+C 实现一键复制文件路径
	; null= 
	send ^c
	sleep,200
	clipboard=%clipboard% ;%null%
	tooltip,%clipboard%
	sleep,500
	tooltip,
	return
return