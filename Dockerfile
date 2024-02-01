# Use a base image
FROM debian:buster-slim

# Set environment variables
ENV FTP_USER=john \
    FTP_PASS=rachel \
    PASV_ADDRESS=127.0.0.1 \
    PASV_MIN_PORT=21100 \
    PASV_MAX_PORT=21110

# Install vsftpd and other required packages
RUN apt-get update && \
    apt-get install -y vsftpd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/

RUN mkdir -p /var/run/vsftpd/empty

# Configure vsftpd
RUN echo "local_enable=YES" >> /etc/vsftpd.conf && \
    echo "write_enable=YES" >> /etc/vsftpd.conf && \
    echo "local_umask=022" >> /etc/vsftpd.conf && \
    echo "chroot_local_user=YES" >> /etc/vsftpd.conf && \
    echo "allow_writeable_chroot=YES" >> /etc/vsftpd.conf && \
    echo "pasv_enable=YES" >> /etc/vsftpd.conf && \
    echo "pasv_address=$PASV_ADDRESS" >> /etc/vsftpd.conf && \
    echo "pasv_min_port=$PASV_MIN_PORT" >> /etc/vsftpd.conf && \
    echo "pasv_max_port=$PASV_MAX_PORT" >> /etc/vsftpd.conf && \
    echo "secure_chroot_dir=/var/run/vsftpd/empty" >> /etc/vsftpd.conf

# Add a user and set the password
RUN useradd -m $FTP_USER && \
    echo "$FTP_USER:$FTP_PASS" | chpasswd

# Expose ports
EXPOSE 20 21 $PASV_MIN_PORT-$PASV_MAX_PORT

# Start vsftpd service
CMD ["vsftpd", "/etc/vsftpd.conf"]