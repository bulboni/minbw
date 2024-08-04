# Gunakan image dasar
FROM debian:latest

# Set non-interaktif untuk mencegah prompt interaktif selama instalasi
ENV DEBIAN_FRONTEND=noninteractive

# Update sistem dan instal paket yang diperlukan
RUN apt update && apt upgrade -y && apt install -y \
    ssh git wget curl ca-certificates gcc \
    libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libxcomposite1 libxrandr2 libgbm1 libxkbcommon0 libpango-1.0-0 libxdamage1 libxshmfence1 libglib2.0-0 libgconf-2-4 libasound2 \
    libx11-xcb1 libxcomposite1 libxcursor1 libxdamage1 libxi6 libxtst6 libnss3 libxss1 libxrandr2 libgbm1 libgtk-3-0 libxshmfence1 libxfixes3

# Instal Node.js secara manual
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Kloning repository ke direktori /bw
RUN git clone https://github.com/gualgeol-code/bw

# Set WORKDIR ke /bw sehingga semua operasi selanjutnya dilakukan dalam direktori ini
WORKDIR /bw

# Hapus node_modules jika ada dan instal npm modules
RUN rm -rf node_modules \
    && npm install

# Memastikan puppeteer versi terbaru diinstal
RUN npm install puppeteer@latest

# Jalankan skrip install.sh
RUN sh install.sh

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
