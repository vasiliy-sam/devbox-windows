$_domainsStr = $args[1]
$_ip_address = $args[3]

$_domainsArr = $_domainsStr.Split(",")
$content = Get-Content -Path "$env:windir/System32/drivers/etc/hosts";
foreach ($_domain in $_domainsArr) {
    $regex = [regex]::Escape("${_ip_address} ${_domain}")
    $content = ($content | Where-Object { $_ -notmatch $regex })
}
$content | Set-Content -Path "$env:windir/System32/drivers/etc/hosts"