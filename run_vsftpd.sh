#!/bin/bash
set -e

# Static FTP directory
FTP_DIR="/home/user/post"

# Create FTP user with specified home directory
useradd -d "${FTP_DIR}" -s /usr/sbin/nologin "${FTP_USER}" && \
echo "${FTP_USER}:${FTP_PASS}" | chpasswd

# Set permissions for the FTP directory
chown "${FTP_USER}":"${FTP_USER}" "${FTP_DIR}"

# Create vsftpd.conf file
cat << EOF > /etc/vsftpd.conf
listen=YES
listen_port=21
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
local_root=${FTP_DIR}
user_sub_token=\$USER
allow_writeable_chroot=YES
EOF

# Start vsftpd
/usr/sbin/vsftpd /etc/vsftpd.conf
