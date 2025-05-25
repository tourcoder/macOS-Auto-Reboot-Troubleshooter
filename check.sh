#!/bin/bash

echo "macOS 自动重启排查工具"
echo "时间: $(date)"
echo "=========================================="

echo "1. 上一次关机原因 (Previous shutdown cause):"
log show --predicate 'eventMessage contains "Previous shutdown cause"' --last 24h --info | tail -n 5
echo "------------------------------------------"

echo "2. WindowServer 或 loginwindow 是否崩溃："
log show --predicate 'process == "WindowServer" OR process == "loginwindow"' --last 2h --info | grep -Ei "exited|crash|error|exit" | tail -n 20
echo "------------------------------------------"

echo "3. 用户 session 中的服务是否被批量退出："
log show --predicate 'eventMessage contains "exited due to SIGKILL"' --last 2h --info | tail -n 20
echo "------------------------------------------"

echo "4. 是否设置了定时唤醒/关机任务（pmset -g sched）："
pmset -g sched
echo "------------------------------------------"

echo "5. 是否启用了自动登录："
auto_login=$(sudo defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser 2>/dev/null)
if [ -z "$auto_login" ]; then
    echo "❌ 未启用自动登录"
else
    echo "✅ 启用了自动登录用户: $auto_login"
fi
echo "------------------------------------------"

echo "6. 是否设置了空闲时自动注销用户："
logout_timer=$(sudo defaults read /Library/Preferences/com.apple.loginwindow com.apple.autologout.AutoLogOutDelay 2>/dev/null)
if [ -z "$logout_timer" ]; then
    echo "❌ 未设置空闲注销"
else
    echo "⚠️ 设置了空闲 $logout_timer 秒后注销用户（约 $(($logout_timer/60)) 分钟）"
fi
echo "=========================================="

echo "排查完毕"
