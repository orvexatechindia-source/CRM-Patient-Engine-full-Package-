# Push this demo to a new GitHub repository in one command (Windows PowerShell).
# Needs Git and the GitHub CLI (https://cli.github.com), signed in once with: gh auth login
# Usage: .\push.ps1 [-Name enquira-full-demo] [-Visibility private|public]   (public also turns on a free GitHub Pages site)
param([string]$Name = "enquira-full-demo", [ValidateSet("private","public")][string]$Visibility = "private")
Set-Location $PSScriptRoot
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { Write-Host "Install the GitHub CLI first: https://cli.github.com"; exit 1 }
gh auth status *> $null; if ($LASTEXITCODE -ne 0) { Write-Host "Sign in first: gh auth login"; exit 1 }
if (-not (Test-Path .git)) { git init -q -b main }
git add -A
git commit -q -m "Enquira Full package early-access demo"
git remote get-url origin *> $null
if ($LASTEXITCODE -eq 0) { git push -u origin main } else { gh repo create $Name --$Visibility --source=. --remote=origin --push }
if ($Visibility -eq "public") { gh api -X POST "repos/{owner}/{repo}/pages" -f build_type=workflow *> $null; $u = gh api user -q .login; Write-Host "GitHub Pages: https://$u.github.io/$Name/ (live in about a minute)" }
Write-Host "Repository: $(gh repo view --json url -q .url)"
