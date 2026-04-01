# 🖥️ Alpine Linux Kiosk Setup (BMAX N4000)

สคริปต์สำหรับติดตั้งระบบ Kiosk อัตโนมัติบน Alpine Linux เพื่อแสดงผลหน้าเว็บคิว (Web Queue) พร้อมระบบเสียงและการเชื่อมต่อ VNC สำหรับเครื่อง BMAX (CPU N4000)

BMAX B1 MINI PC

## 📋 ติดตั้ง Alpine linux และเตรียมระบบ SSH ให้เรียบร้อยก่อนจะ git

## 📋 สิ่งที่สคริปต์ทำ
* อัปเดตแพ็กเกจและติดตั้ง Driver (Intel, Sound, Xorg)
* สร้าง User `kiosk` และตั้งค่า Auto Login
* ติดตั้ง Openbox และ Chromium แบบเต็มจอ (Kiosk Mode)
* ตั้งค่าระบบเสียง (ALSA/PulseAudio) ให้ default ออกที่ช่อง 3.5mm/HDMI ตาม config
* ติดตั้ง VNC Server ให้รีโมทเข้ามาดูหน้าจอได้
* **Optimization:** ย้าย Log/Temp ลง RAM และปิด Swap เพื่อถนอม eMMC

---

## 🚀 วิธีการติดตั้ง (Installation)

1. **ล็อกอินเข้า Alpine Linux ด้วย user `root`**

2. **ติดตั้ง Git ดึงสคริปต์และติดตั้ง**
   ```bash
   apk add git
   git clone https://github.com/itstmcp/bmax-pq.git
   cd bmax-pq
   chmod +x install.sh
    ./install.sh
   ```
3. Reboot
   ```bash
   reboot
   ```
-------------------------------------------------------------------------------
คำสั่งที่เกี่ยวข้อง
-------------------------------------------------------------------------------
# test TTS sound api
  ```
  apk add espeak-ng
  su - kiosk
  espeak-ng "Hello testing sound"
  ```

# เปิดเสียง Master และปรับความดัง 100% / บางเครื่องอาจต้องเปิดช่อง PCM หรือ Speaker ด้วย
  ```
  amixer sset Master unmute
  amixer sset Master 100%

  amixer sset PCM unmute
  amixer sset PCM 100%
  ```

# ปรับแบบเสียง GUI
  ```
  alsamixer

  # เสร็จแล้วบันทึกค่าด้วยคำสั่งนี้ทุกครั้ง
  alsactl store
  ```

# Soundcard Check
  ```
  aplay -l
  ```

# speaker test ////////////////////////////////////////////////////
  ```
  speaker-test -t wav -c 2

  # เปลี่ยนเลขข้างหลัง plughw:X,Y ไปเรื่อยๆ เช่น 0,3, 0,7, 1,3 จนกว่าจะได้ยินเสียง
  speaker-test -t wav -c 2 -D plughw:0,3
  ```

# เปลี่ยนการบังคับใช้ Soundcard
  ```
  nano /etc/asound.conf

  alsactl store
  ```

# Auto Start config
  ```
  nano /home/kiosk/.config/openbox/autostart
  ```

# ปิด Swap (ถ้ามี) เช็คในไฟล์ /etc/fstab ถ้ามีบรรทัดไหนเขียนว่า swap ให้ลบออกหรือใส่ # ไว้ข้างหน้าครับ (RAM 8GB ไม่ต้องใช้ Swap ให้เปลือง eMMC)
  ```
  nano /etc/fstab
  ```

# Auto login
  ```
  nano /etc/inittab
  tty1::respawn:/bin/login -f kiosk
  ```
  
