<#
.SYNOPSIS
    Return a Datadog client configuration.
.DESCRIPTION
    Return a Datadog client configuration that can be supplied as a parameter to Add-SinkDataDog.
    This is important if you need to provide a different Url.
.LINK
    https://docs.datadoghq.com/logs/log_collection/?tab=host#supported-endpoints
.EXAMPLE
    PS> $config = New-SinkDataDogConfiguration -Url = "https://http-intake.logs.us3.datadoghq.com"
    PS> New-Logger | Add-SinkDataDog -ApiKey abc123 -Configuration $config | Start-Logger
.INPUTS
    String
.OUTPUTS
    Serilog.Sinks.Datadog.Logs.DatadogConfiguration
#>
function New-SinkDataDogConfiguration {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Url,

        [Parameter()]
        [int]
        $Port,

        [Parameter()]
        [bool]
        $UseSsl,

        [Parameter()]
        [bool]
        $UseTcp
    )

    $configuration = [Serilog.Sinks.Datadog.Logs.DatadogConfiguration]::new()

    switch ($true) {
        { $PSBoundParameters.ContainsKey('Url') } { $configuration.Url = $Url }
        { $PSBoundParameters.ContainsKey('Port') } { $configuration.Port = $Port }
        { $PSBoundParameters.ContainsKey('UseSsl') } { $configuration.UseSSL = $UseSsl }
        { $PSBoundParameters.ContainsKey('UseTcp') } { $configuration.UseTCP = $UseTcp }
    }

    $configuration
}