FROM phpswoole/swoole:php8.4

RUN apt-get update && apt-get install -y \
    inotify-tools \
    bash \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pcntl mysqli

# Copy composer from official image
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Install dependencies
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader

# Copy application code
COPY src/ ./src/

ENTRYPOINT ["vendor/bin/mononoke", "src/Service.php"]