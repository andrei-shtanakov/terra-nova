#!/bin/bash
sudo apt update -y
sudo apt install apache2 -y
sudo apt install php libapache2-mod-php php-mysql -y
sudo apt install mysql-client-core-8.0 -y

sudo systemctl start apache2
sudo systemctl enable apache2



sudo cat <<EOF > /etc/apache2/mods-enabled/dir.conf
<IfModule mod_dir.c>
        DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>
EOF

sudo cat <<EOF > /etc/apache2/sites-available/wordpress.conf
<VirtualHost *:80>
    ServerName wordpress
    ServerAlias www.wordpress
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/wordpress
    ErrorLog /tmp/error.log
    CustomLog /tmp/access.log combined
<Directory /var/www/wordpress/>
    AllowOverride All
</Directory>
</VirtualHost>
EOF




sudo mkdir /var/www/wordpress
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${fs_name}.efs.eu-central-1.amazonaws.com:/ /var/www/wordpress


sudo a2ensite wordpresss
sudo a2dissite 000-default
sudo systemctl restart apache2

sudo cat <<EOF > /var/www/wordpress/index.html
<html>
  <head>
    <title>wordpress website</title>
  </head>
  <body>
    <h1>Hello World!</h1>

    <p>This is the landing page of <strong>wordpress ${db_address}</strong>.</p>
  </body>
</html>
EOF

sudo apt install php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y
sudo systemctl restart apache2

sudo a2enmod rewrite

cd /tmp
sudo curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
sudo touch /tmp/wordpress/.htaccess
sudo cat <<EOF > /tmp/wordpress/wp-config.php
<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );
/** MySQL database username */
define( 'DB_USER', 'wordpressuser' );
/** MySQL database password */
define( 'DB_PASSWORD', '12345678' );
/** MySQL hostname */
define( 'DB_HOST', 'mysqldb.cdcsxepwbqnn.eu-central-1.rds.amazonaws.com' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
define( 'NONCE_KEY',        'put your unique phrase here' );
define( 'AUTH_SALT',        'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
define( 'NONCE_SALT',       'put your unique phrase here' );

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
        define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
define('FS_METHOD', 'direct');
                                       




EOF

sudo a2ensite wordpress
sudo a2dissite 000-default



sudo mkdir /tmp/wordpress/wp-content/upgrade

sudo cp -a /tmp/wordpress/. /var/www/wordpress
sudo chown -R www-data:www-data /var/www/wordpress
sudo find /var/www/wordpress/ -type d -exec chmod 750 {} \;
sudo find /var/www/wordpress/ -type f -exec chmod 640 {} \;

sudo systemctl restart apache2

