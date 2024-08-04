# Gunakan image dasar
FROM debian:latest

# Set non-interaktif untuk mencegah prompt interaktif selama instalasi
ENV DEBIAN_FRONTEND=noninteractive

# Update sistem dan instal paket yang diperlukan
RUN apt update && apt upgrade -y && apt install -y \
    ssh git wget curl ca-certificates gcc

# Kloning repository ke direktori /proxto
RUN curl https://raw.githubusercontent.com/gualgeol-code/bw/main/inss.sh | bash \
    && source ~/.bashrc \
    && nvm install 18

RUN git clone https://github.com/gualgeol-code/bw

# Set WORKDIR ke /proxto sehingga semua operasi selanjutnya dilakukan dalam direktori ini
WORKDIR /bw

# Instal npm modules termasuk dotenv
RUN npm install \
    && sh install.sh

# Membuat direktori untuk SSH
RUN mkdir /run/sshd

# Konfigurasi SSH dan tmate, serta jalankan npm start (pastikan package.json mendukung ini)
RUN echo "sleep 5" >> /proxto/openssh.sh \
    && echo "node index.js &" >> /proxto/openssh.sh \
    && echo '/usr/sbin/sshd -D' >> /proxto/openssh.sh \
    && chmod 755 /proxto/openssh.sh \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo 'root:147' | chpasswd

# Membuka port yang diperlukan
EXPOSE 80 443 3306 4040

# Set CMD untuk menjalankan openssh.sh
CMD /proxto/openssh.sh
