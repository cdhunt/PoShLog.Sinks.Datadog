function Add-SinkDataDog {
	<#
	.SYNOPSIS
		Writes log events into seq
	.DESCRIPTION
		Writes log events into seq server
	.PARAMETER LoggerConfig
		Instance of LoggerConfiguration
	.PARAMETER ApiKey
		Your Datadog API key.
	.PARAMETER Source
		The integration name.
	.PARAMETER Service
		The service name.
	.PARAMETER Host
		The host name. Default is the output of the hostname command.
	.PARAMETER Environment
		Add the env tag with the provided value.
	.PARAMETER Version
		Add the version tag with the provided value.
	.PARAMETER Tags
		Custom tags in key:value format.
	.PARAMETER configuration
		The Datadog logs client configuration.
	.PARAMETER configurationSection
		A config section defining the datadog configuration.
	.PARAMETER RestrictedToMinimumLevel
		The minimum level for events passed through the sink. Ignored when LevelSwitch is specified.
	.PARAMETER BatchPostingLimit
		The maximum number of events to post in a single batch.
	.PARAMETER Period
		The time to wait between checking for event batches
	.PARAMETER QueueSizeLimit
		Maximum number of events to hold in the sink's internal queue , or $null
        for an unbounded queue. The default is 10000.
	.PARAMETER ExceptionHandler
		This function is called when an exception occurs when using
        DatadogConfiguration.UseTCP=false (the default configuration)
		eg. [Action[Exception]]{param ([Exception]$e) Write-Error -Message "DataDog Serilog Sink encountered an error" -Exception $e}
	.PARAMETER MessageHandler
		Used to construct the HttpClient that will send the log messages to Seq.
	.PARAMETER RetainedInvalidPayloadsLimitBytes
		A soft limit for the number of bytes to use for storing failed requests.
		The limit is soft in that it can be exceeded by any single error payload, but in that case only that single error payload will be retained.
	.PARAMETER Compact
		Use the compact log event format defined by Serilog.Formatting.Compact. Has no effect on durable log shipping.
	.PARAMETER QueueSizeLimit
		The maximum number of events that will be held in-memory while waiting to ship them to Seq.
		Beyond this limit, events will be dropped. The default is 100,000. Has no effect on durable log shipping.
	.INPUTS
		Serilog.LoggerConfiguration
	.OUTPUTS
		Serilog.LoggerConfiguration
	.EXAMPLE
		PS> New-Logger | Add-SinkDataDog -ApiKey abc123 | Start-Logger
	.LINK
		https://github.com/DataDog/serilog-sinks-datadog-logs
	.LINK
		https://docs.datadoghq.com/getting_started/tagging/unified_service_tagging/
	#>

	[Cmdletbinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[Serilog.LoggerConfiguration]$LoggerConfig,

		[Parameter()]
		[string]$ApiKey = $env:DD_API_KEY,

		[Parameter()]
		[string]$Source,

		[Parameter()]
		[string]$Service,

		[Parameter()]
		[string]$HostName = (hostname),

		[Parameter()]
		[string]$Environment,

		[Parameter()]
		[string[]]
		$Tags,

		[Parameter()]
		[Serilog.Sinks.Datadog.Logs.DatadogConfiguration]
		$Configuration,

		[Parameter()]
		[Microsoft.Extensions.Configuration.IConfigurationSection]
		$ConfigurationSection,

		[Parameter(ParameterSetName = 'RestrictedToMinimumLevel')]
		[Serilog.Events.LogEventLevel]$RestrictedToMinimumLevel = [Serilog.Events.LogEventLevel]::Information,

		[Parameter()]
		[Nullable[int]]$BatchPostingLimit = $null,

		[Parameter()]
		[Nullable[System.Timespan]]$Period = $null,

		[Parameter()]
		[Nullable[int]]$QueueSizeLimit = 10000,

		[Parameter()]
		[Action[Exception]]$ExceptionHandler = $null,

		[Parameter()]
		[bool]$DetectTCPDisconnection
	)

	if ($PSBoundParameters.ContainsKey('Environment')) {
		$Tags += "env:$Environment"
	}

	if ($PSBoundParameters.ContainsKey('Version')) {
		$Tags += "version:$Version"
	}

	if ([string]::IsNullOrEmpty($ApiKey)) {
		Write-Error -Message "You must provide an ApiKey either using the ApiKey parameter or the DD_API_KEY environment variable."
	}

	$LoggerConfig = [Serilog.LoggerConfigurationDatadogExtensions]::DatadogLogs($LoggerConfig.WriteTo,
		$ApiKey,
		$Source,
		$Service,
		$HostName,
		$Tags,
		$Configuration,
		$ConfigurationSection,
		$RestrictedToMinimumLevel,
		$BatchSizeLimit,
		$Period,
		$QueueSizeLimit,
		$ExceptionHandler,
		$DetectTCPDisconnection
	)

	$LoggerConfig
}