<?php

namespace Riichi;

class Sysconf
{
    const SINGLE_MODE = false;
    const OVERRIDE_EVENT_ID = 1;
    const SUPER_ADMIN_PASS = 'hjpjdstckjybrb';
    const SUPER_ADMIN_COOKIE = 'kldfmewmd9vbeiogbjsdvjepklsdmnvmn';

    public static function ADMIN_AUTH() {
        return [
            1 => ['cookie' => 'verysecretcookie', 'password' => 'password'],
        ];
    }

    // Common settings
    const API_VERSION_MAJOR = 1;
    const API_VERSION_MINOR = 0;
    const DEBUG_MODE = true;
    const API_ADMIN_TOKEN = 'CHANGE_ME';

    public static function API_URL() {
        return getenv('MIMIR_URL');
    }
}