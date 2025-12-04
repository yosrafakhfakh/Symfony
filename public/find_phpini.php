<?php
echo "=== PHP.INI DU SERVEUR WEB ===\n\n";
echo "Loaded Configuration File: " . php_ini_loaded_file() . "\n\n";
echo "Scan this dir for additional .ini files: " . php_ini_scanned_files() . "\n\n";
echo "=== EXTENSIONS CHARGEES ===\n";
$extensions = get_loaded_extensions();
if (in_array('fileinfo', $extensions)) {
    echo "✓ Extension fileinfo est ACTIVE\n";
} else {
    echo "✗ Extension fileinfo est INACTIVE\n";
}
echo "\n=== LISTE DES EXTENSIONS ===\n";
sort($extensions);
foreach ($extensions as $ext) {
    echo "- $ext\n";
}
