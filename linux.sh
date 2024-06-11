#!/bin/bash

# 检查系统发行版
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "无法检测操作系统。"
    exit 1
fi

echo "检测到操作系统为: $OS"

# 更新系统
update_system() {
    echo "开始更新系统..."
    case $OS in
        centos)
            yum update -y && echo "系统更新完成。" || echo "更新失败！"
            ;;
        debian|ubuntu)
            apt-get update && apt-get upgrade -y && echo "系统更新完成。" || echo "更新失败！"
            ;;
        *)
            echo "不支持的操作系统：$OS"
            exit 1
            ;;
    esac
}

# 清理系统垃圾
clean_system() {
    echo "开始清理系统..."
    case $OS in
        centos)
            yum autoremove -y && yum clean all && echo "系统清理完成。" || echo "清理失败！"
            ;;
        debian|ubuntu)
            apt-get autoreceive -y && apt-get clean && echo "系统清理完成。" || echo "清理失败！"
            ;;
        *)
            echo "不支持的操作系统：$OS"
            exit 1
            ;;
    esac
}

# 设置虚拟内存（Swap）
set_swap() {
    echo "开始设置虚拟内存..."
    dd if=/dev/zero of=/swapfile bs=1M count=1024 && \
    chmod 600 /swapfile && \
    mkswap /swapfile && \
    swapon /swapfile && \
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab && echo "虚拟内存设置完成。" || echo "设置虚拟内存失败！"
}

# 开启BBR
enable_bbr() {
    echo "开始启用BBR..."
    echo "net.core.default_qdisc=fq" | tee -a /etc/sysctl.conf && \
    echo "net.ipv4.tcp_congestion_control=bbr" | tee -a /etc/sysctl.conf && \
    sysctl -p && echo "BBR启用完成。" || echo "启用BBR失败！"
}

# 修改时区为中国上海，并确认使用24小时制
set_timezone_and_time_format() {
    echo "设置时区为中国上海..."
    timedatectl set-timezone Asia/Shanghai && echo "时区设置完成。" || echo "时区设置失败！"
    localectl set-locale LC_TIME=en_GB.UTF-8
}

# 执行所有步骤
perform_all_tasks() {
    echo "开始执行所有配置步骤..."
    update_system
    clean_system
    set_swap
    enable_bbr
    set_timezone_and_time_format
    echo "所有步骤执行完毕。"
}

# 菜单系统
while true; do
    echo "请选择要执行的操作:"
    echo "1) 更新系统"
    echo "2) 清理系统"
    echo "3) 设置虚拟内存"
    echo "4) 开启BBR"
    echo "5) 修改时区和时间格式"
    echo "6) 一键执行全部任务"
    echo "7) 退出"
    read -p "输入选项 (1-7): " choice
    case "$choice" in
        1) update_system ;;
        2) clean_system ;;
        3) set_swap ;;
        4) enable_bbr ;;
        5) set_timezone_and_time_format ;;
        6) perform_all_tasks ;;
        7) echo "退出脚本。"; break ;;
        *) echo "无效选项，请重新输入。" ;;
    esac
done

echo "所有设置已完成。"
