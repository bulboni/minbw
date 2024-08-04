# Gunakan image dasar
FROM debian:latest

# Set non-interaktif untuk mencegah prompt interaktif selama instalasi
ENV DEBIAN_FRONTEND=noninteractive

# Update sistem dan instal paket yang diperlukan
RUN apt update && apt upgrade -y && apt install -y \
    ssh git wget curl ca-certificates gcc

# Instal Node.js secara manual
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Kloning repository ke direktori /bw
RUN git clone https://github.com/gualgeol-code/bw

# Set WORKDIR ke /bw sehingga semua operasi selanjutnya dilakukan dalam direktori ini
WORKDIR /bw

# Instal npm modules termasuk dotenv
RUN npm install \
    && npm install puppeteer@latest \
    && sh install.sh

# Membuat direktori untuk SSH
RUN mkdir /run/sshd

# Konfigurasi SSH dan tmate, serta jalankan npm start (pastikan package.json mendukung ini)
RUN echo "sleep 5" >> /bw/openssh.sh \
    && echo "node index.js &" >> /bw/openssh.sh \
    && echo '/usr/sbin/sshd -D' >> /bw/openssh.sh \
    && chmod 755 /bw/openssh.sh \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo 'root:147' | chpasswd

# Membuka port yang diperlukan
EXPOSE 80 443 3306 4040

# Set CMD untuk menjalankan openssh.sh
CMD /bw/openssh.sh
