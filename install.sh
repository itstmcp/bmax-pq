#!/bin/sh

# ตรวจสอบว่าเป็น root หรือไม่
if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root" 
   exit 1
fi

echo "=== 1. Updating Repositories & System ==="
# เปิด Community repo (วิธีแบบ sed เพื่อแก้ไฟล์)
sed -i 's/^#//g' /etc/apk/repositories
apk update
apk upgrade

echo "=== 2. Installing Packages ==="
# รวมแพ็กเกจทั้งหมดไว้ในคำสั่งเดียวเพื่อความเร็ว
apk add xorg-server xf86-video-intel mesa-dri-gallium mesa-va-gallium \
    xinit dbus-x11 alsa-utils alsa-lib util-linux openbox chromium \
    font-noto-thai ttf-dejavu linux-firmware-intel sof-firmware \
    alsa-ucm-conf pulseaudio pulseaudio-alsa alsa-plugins-pulse \
    espeak-ng tigervnc x11vnc

echo "=== 3. Setting up User 'kiosk' ==="
# สร้าง user ถ้ายังไม่มี
id -u kiosk &>/dev/null || adduser -D kiosk
# เพิ่มเข้ากลุ่มต่างๆ
addgroup kiosk audio 2>/dev/null
addgroup kiosk input 2>/dev/null
addgroup kiosk video 2>/dev/null

echo "=== 4. Configuring Audio (ALSA/Pulse) ==="
# ลบ config เก่า
rm -rf /home/kiosk/.config/pulse
rm -rf /home/kiosk/.local/state/wireplumber
rm -rf /tmp/pulse-*

# Copy asound.conf
cp configs/asound.conf /etc/asound.conf

# Set Audio Volume
amixer sset Master unmute
amixer sset Master 100%
amixer sset PCM unmute 2>/dev/null
amixer sset PCM 100% 2>/dev/null
alsactl store

echo "=== 5. Configuring VNC ==="
mkdir -p /home/kiosk/.vnc
# ตั้งรหัส VNC (เปลี่ยน 'password' เป็นรหัสที่คุณต้องการ)
x11vnc -storepasswd "tm11354" /home/kiosk/.vnc/passwd
chown -R kiosk:kiosk /home/kiosk/.vnc

echo "=== 6. Configuring Openbox & Autostart ==="
mkdir -p /home/kiosk/.config/openbox
cp configs/autostart /home/kiosk/.config/openbox/autostart
cp configs/.xinitrc /home/kiosk/.xinitrc
cp configs/.profile /home/kiosk/.profile

# แก้ไขสิทธิ์ไฟล์ทั้งหมดใน home ของ kiosk
chown -R kiosk:kiosk /home/kiosk

echo "=== 7. Configuring Auto Login ==="
# แก้ไฟล์ inittab เพื่อ auto login
sed -i 's|tty1::respawn:/sbin/getty 38400 tty1|tty1::respawn:/bin/login -f kiosk|' /etc/inittab

echo "=== 8. Optimize System (RAM Logs & Disable Swap) ==="

# 1. เพิ่มการตั้งค่าให้เก็บ Log และ Temp ลง RAM (tmpfs)
# เช็คก่อนว่ามีอยู่แล้วไหม เพื่อกันการเขียนซ้ำ
if ! grep -q "tmpfs /tmp" /etc/fstab; then
    echo "tmpfs    /tmp        tmpfs    defaults,noatime,mode=1777    0    0" >> /etc/fstab
fi

if ! grep -q "tmpfs /var/log" /etc/fstab; then
    echo "tmpfs    /var/log    tmpfs    defaults,noatime,mode=0755    0    0" >> /etc/fstab
fi

# 2. ปิด Swap (โดยการใส่เครื่องหมาย # หน้าบรรทัดที่มีคำว่า swap)
sed -i '/swap/s/^/#/' /etc/fstab

echo "=== INSTALLATION COMPLETE ==="
echo "Please type 'lbu commit -d' if you are running in Diskless Mode."
echo "Then type 'reboot' to test."
