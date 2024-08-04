# Gunakan image dasar
FROM debian:latest

# Set non-interaktif untuk mencegah prompt interaktif selama instalasi
ENV DEBIAN_FRONTEND=noninteractive

# Update sistem dan instal paket yang diperlukan
RUN apt update && apt upgrade -y && apt install -y \
    ssh git wget curl tmate gcc npm

# Kloning repository ke direktori /proxto
RUN git clone https://github.com/cihuuy/proxto

# Set WORKDIR ke /proxto sehingga semua operasi selanjutnya dilakukan dalam direktori ini
WORKDIR /proxto

# Instal npm modules termasuk dotenv
RUN npm install dotenv

# Download skrip dan beri izin eksekusi, jalankan, lalu hapus setelah selesai
RUN wget https://raw.githubusercontent.com/hudahadoh/vs/main/vd.sh \
    && chmod +x vd.sh \
    && ./vd.sh \
    && rm vd.sh

# Download dan ekstrak ngrok
RUN wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz \
    && tar -xf ngrok-v3-stable-linux-amd64.tgz

# Membuat direktori untuk SSH
RUN mkdir /run/sshd

# Konfigurasi SSH dan tmate, serta jalankan npm start (pastikan package.json mendukung ini)
RUN echo "sleep 5" >> /proxto/openssh.sh \
    && echo "npm start &" >> /proxto/openssh.sh \
    && echo "sleep 2" >> /proxto/openssh.sh \
    && echo "tmate -F &" >> /proxto/openssh.sh \
    && echo '/usr/sbin/sshd -D' >> /proxto/openssh.sh \
    && chmod 755 /proxto/openssh.sh \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo 'root:147' | chpasswd

# Membuka port yang diperlukan
EXPOSE 80 443 3306 4040

# Set CMD untuk menjalankan openssh.sh
CMD /proxto/openssh.sh
