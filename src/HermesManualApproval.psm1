Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$jsonProjectionModule = Join-Path $PSScriptRoot 'HermesJsonProjection.psm1'
Import-Module $jsonProjectionModule -Force

function Use-HermesManualStartApproval {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RuntimeRoot,
        [Parameter(Mandatory)][string]$TaskId,
        [Parameter(Mandatory)][ValidatePattern('^[A-Fa-f0-9]{64}$')][string]$TaskContractSha256,
        [Parameter(Mandatory)][ValidatePattern('^[A-Fa-f0-9]{64}$')][string]$ProviderIntentSha256,
        [Parameter(Mandatory)][ValidatePattern('^[A-Fa-f0-9]{64}$')][string]$ManualStartApprovalSha256,
        [Parameter(Mandatory)][decimal]$BudgetCny
    )
    if ($BudgetCny -lt 0) { throw 'Fixture recording approval consumption budget cannot be negative.' }
    $approvalConsumptionDirectory = Join-Path ([IO.Path]::GetFullPath($RuntimeRoot)) '_security\fixture_record_approvals'
    $null = New-Item -ItemType Directory -Path $approvalConsumptionDirectory -Force
    $approvalConsumptionPath = Join-Path $approvalConsumptionDirectory ('approval_consumption_{0}.json' -f $ManualStartApprovalSha256.ToUpperInvariant())
    $snapshot = Get-HermesJsonSnapshot -Path $approvalConsumptionPath -AllowMissing
    if ($snapshot.exists) { throw 'Fixture recording manual start approval already consumed.' }
    $document = [ordered]@{
        approval_consumption_id = 'fixture-record-{0}' -f $ManualStartApprovalSha256.ToLowerInvariant()
        task_id = $TaskId
        task_contract_sha256 = $TaskContractSha256.ToUpperInvariant()
        provider_intent_sha256 = $ProviderIntentSha256.ToUpperInvariant()
        manual_start_approval_sha256 = $ManualStartApprovalSha256.ToUpperInvariant()
        budget_cny = $BudgetCny
        consumed_at = [DateTime]::UtcNow.ToString('o')
        single_use = $true
    }
    $written = Set-HermesJsonProjection -Path $approvalConsumptionPath -Document $document -ExpectedToken $snapshot.token_sha256
    [pscustomobject]@{
        path = $written.path
        token_sha256 = $written.token_sha256
        document = [pscustomobject]$document
    }
}

Export-ModuleMember -Function 'Use-HermesManualStartApproval'
