# Obtenha as conexoes RDP estabelecidas na porta 3389
$rdpConnections = netstat -n | findstr ":3389.*ESTABLISHED"
Write-Host "Conexoes RDP Estabelecidas: `n$rdpConnections`n"

# Inicializar uma lista para armazenar IPs remotos
$remoteIPs = @()
$rdpConnections -replace "\s+", " " | ForEach-Object {
    if ($_ -match "(\d+\.\d+\.\d+\.\d+):\d*\s+(\d+\.\d+\.\d+\.\d+):\d*\s+ESTABLISHED") {
        $remoteIPs += $matches[2]
    }
}

# Inicializa a variavel de conexao encontrada
$conexaoEncontrada = $false

# Obtenha as sessoes de usuarios conectados
$sessionsRaw = qwinsta /server:localhost

# Analise a saida das sessoes do qwinsta
$sessionsRaw -split "`n" | ForEach-Object {
    if ($_ -match "^\s*(\S+)\s+(\S*)\s+(\d+)\s+(\w+)\s+(\w+)\s*(\S*)") {
        $sessionName = $matches[1]
        $username = $matches[2]
        $sessionId = $matches[3]
        $state = $matches[4]
        
        # Verifica se o estado da sessao e "Ativo"
        if ($state -eq "Ativo") {
            Write-Host "Sessao: $sessionName | Usuario: $username | ID: $sessionId | Estado: $state"

            # Verifique se temos algum IP de conexao remota associado a esse estado ativo
            if ($remoteIPs.Count -gt 0) {
                $conexaoEncontrada = $true
                foreach ($ip in $remoteIPs) {
                    Write-Output "Usuario: $username | Sessao ID: $sessionId | IP Remoto: $ip"
                }
            }
        }
    }
}

# Verifique se nenhuma conexao foi encontrada
if (-not $conexaoEncontrada) {
    Write-Output "Nenhuma conexao no momento."
}