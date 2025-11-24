FROM php:8.2-apache

# Install system deps + PHP extensions (PDO MySQL + others for LavaLust)
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    && docker-php-ext-install pdo pdo_mysql zip

# Enable Apache mod_rewrite (for routes)
RUN a2enmod rewrite

# Install Composer globally
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && rm composer-setup.php

# Copy app files
COPY . /var/www/html/

# Install Composer dependencies (add this!)
WORKDIR /var/www/html
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Set document root to public/
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

# Update Apache config to use the new document root
RUN sed -ri \
    -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf

RUN sed -ri \
    -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/apache2.conf \
    /etc/apache2/conf-available/*.conf

# Permissions (good as is)
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

EXPOSE 80