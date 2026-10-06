$filepath
$hash_of_backup

if not_found or is_file_changed(file_pth, hash):
    restore_from_backup
    log()

is_file_changed(file, hash):
    return compare(hash(file), hash)