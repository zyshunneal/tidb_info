#!/usr/bin/env bash
# TiDB 节点 OS 准备脚本 (Debian 12 arm64)
# 通过 ssh + sudo bash -s < 此脚本 在三台 VM 上各跑一次, idempotent
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

echo "[1/6] apt update + 安装 chrony / numactl"
apt-get update -qq
apt-get install -y --no-install-recommends chrony numactl tar
systemctl enable --now chrony

echo "[2/6] 关 swap"
swapoff -a || true
if [ -f /etc/fstab ] && grep -qE '^\S+\s+\S+\s+swap\s' /etc/fstab; then
  cp -n /etc/fstab /etc/fstab.bak
  sed -i -E 's|^(\S+\s+\S+\s+swap\s.*)$|# \1|' /etc/fstab
fi

echo "[3/6] 关透明大页 (THP)"
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag
cat >/etc/systemd/system/disable-thp.service <<'UNIT'
[Unit]
Description=Disable Transparent Huge Pages
DefaultDependencies=no
After=sysinit.target local-fs.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c "echo never > /sys/kernel/mm/transparent_hugepage/enabled; echo never > /sys/kernel/mm/transparent_hugepage/defrag"

[Install]
WantedBy=basic.target
UNIT
systemctl daemon-reload
systemctl enable disable-thp.service >/dev/null 2>&1 || true

echo "[4/6] sysctl 调优"
cat >/etc/sysctl.d/99-tidb.conf <<'SYSCTL'
net.core.somaxconn = 32768
net.ipv4.tcp_syncookies = 0
fs.file-max = 1000000
vm.swappiness = 0
vm.overcommit_memory = 1
SYSCTL
sysctl --system >/dev/null

echo "[5/6] limits"
cat >/etc/security/limits.d/99-tidb.conf <<'LIMITS'
tidb soft nofile 1000000
tidb hard nofile 1000000
tidb soft stack 32768
tidb hard stack 32768
tidb soft core unlimited
tidb hard core unlimited
LIMITS

echo "[6/7] SELinux 占位文件 + setenforce 桩 (绕过 TiUP --apply 在 Debian 上的硬编码 RHEL 路径)"
install -d -m 0755 /etc/selinux
if [ ! -f /etc/selinux/config ]; then
  echo "SELINUX=disabled" > /etc/selinux/config
fi
if [ ! -x /usr/local/sbin/setenforce ]; then
  cat >/usr/local/sbin/setenforce <<'STUB'
#!/bin/sh
# Stub for TiUP check --apply on Debian (no SELinux kernel module)
exit 0
STUB
  chmod 0755 /usr/local/sbin/setenforce
fi

echo "[7/7] 建 tidb 用户 + 免密 sudo + ~/.ssh"
id -u tidb >/dev/null 2>&1 || useradd -m -s /bin/bash tidb
install -d -m 0755 /etc/sudoers.d
cat >/etc/sudoers.d/tidb <<'SUDO'
tidb ALL=(ALL) NOPASSWD:ALL
Defaults:tidb !requiretty
SUDO
chmod 0440 /etc/sudoers.d/tidb
install -d -m 0700 -o tidb -g tidb /home/tidb/.ssh
touch /home/tidb/.ssh/authorized_keys
chown tidb:tidb /home/tidb/.ssh/authorized_keys
chmod 0600 /home/tidb/.ssh/authorized_keys

echo "=== DONE on $(hostname) ==="
echo "swap_kb=$(awk '/^SwapTotal:/{print $2}' /proc/meminfo)"
echo "thp=$(cat /sys/kernel/mm/transparent_hugepage/enabled)"
echo "chrony=$(systemctl is-active chrony)"
echo "tidb_uid=$(id -u tidb)"
