. require_once "${devbox_root}/tools/system/output.ps1"

############################ Public functions ############################

# $_domains - comma-separated list
function add_website_domain_to_hosts($_domains = "", $_ip_address = "127.0.0.1") {
    if ($_domains -eq "") {
        show_error_message "Unable to add website to hosts file. Website domain cannot be empty"
        Exit 1
    }

    $_hosts_filepath = "$env:windir/System32/drivers/etc/hosts"
    $_domainsArr = $_domains.Split(",")
    $_addDomainsStr = ""
    foreach ($_domain in $_domainsArr) {
        $_regex_hosts_record = [regex]::Escape("${_ip_address} ${_domain}")
        if (-not (Select-String -Path $_hosts_filepath -Pattern "^${_regex_hosts_record}$")) {
            if ($_addDomainsStr -ne "") {
                $_addDomainsStr += "`r`n"
            }
            $_addDomainsStr += "${_ip_address} ${_domain}"
        }
    }
    if ($_addDomainsStr -ne "") {
        Start-Process PowerShell -Verb RunAs -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass", "Add-Content -Encoding UTF8 -Path '${_hosts_filepath}' -Value '$_addDomainsStr'"
    }
}

# $_domains - comma-separated list
function delete_website_domain_from_hosts($_domains = "", $_ip_address = "127.0.0.1") {
    if ($_domains -eq "") {
        show_error_message "Unable to remove website from hosts file. Website domain cannot be empty"
        Exit 1
    }

    $_hosts_filepath = "$env:windir/System32/drivers/etc/hosts"
    $_domainsArr = $_domains.Split(",")
    $_rmDomains = ""
    foreach ($_domain in $_domainsArr) {
        $_regex_hosts_record = [regex]::Escape("${_ip_address} ${_domain}")
        if (Select-String -Path $_hosts_filepath -Pattern "${_regex_hosts_record}") {
            if ($_rmDomains -ne "") {
                $_rmDomains += ","
            }
            $_rmDomains += $_domain
        }
    }

    if ($_rmDomains -ne "") {
        Start-Process PowerShell -Verb RunAs -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass", "-File ${devbox_root}/tools/system/rm_hosts.ps1", "-domains ${_rmDomains}", "-ip ${_ip_address}"
    }
}

############################ Public functions end ############################
