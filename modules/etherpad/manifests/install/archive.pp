class etherpad::install::archive ($install_config, $etherpad_root_dir = '/opt/etherpad') {

    $_install_config = merge({
        'url_extension' => 'tar.gz',
        'checksum_type' => 'sha1'
    }, $install_config)

    $url_parent     = $_install_config['url_parent']
    $url_filename   = $_install_config['url_filename']
    $url_extension  = $_install_config['url_extension']
    $checksum       = $_install_config['checksum']
    $checksum_type  = $_install_config['checksum_type']

    # Download and unpack the archive
    archive { "${url_filename}":
        ensure          => present,
        url             => "${url_parent}/${url_filename}.${url_extension}",
        target          => $app_root_dir,
        digest_string   => $checksum,
        digest_type     => $checksum_type,
        extension       => $url_extension,
    }
}
