# Update HappyLife.sln to include all new Kubernetes files
# Please close Visual Studio before running this script

$solutionPath = "HappyLife.sln"

# Backup the current solution file
Copy-Item $solutionPath "$solutionPath.backup" -Force
Write-Host "Backed up solution file to $solutionPath.backup" -ForegroundColor Green

# Create the updated solution content
$solutionContent = @"
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 17
VisualStudioVersion = 17.0.31903.59
MinimumVisualStudioVersion = 10.0.40219.1
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "HappyLife", "HappyLife\HappyLife.csproj", "{A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D}"
EndProject
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "HappyLifeInterfaces", "HappyLifeInterfaces\HappyLifeInterfaces.csproj", "{B2C3D4E5-F6A7-4B5C-9D0E-1F2A3B4C5D6E}"
EndProject
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "HappyLifeModels", "HappyLifeModels\HappyLifeModels.csproj", "{C3D4E5F6-A7B8-4C5D-0E1F-2A3B4C5D6E7F}"
EndProject
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "HappyLifeRepository", "HappyLifeRepository\HappyLifeRepository.csproj", "{D4E5F6A7-B8C9-4D5E-1F2A-3B4C5D6E7F8A}"
EndProject
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "HappyLifeServices", "HappyLifeServices\HappyLifeServices.csproj", "{E5F6A7B8-C9D0-4E5F-2A3B-4C5D6E7F8A9B}"
EndProject
Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "Solution Items", "Solution Items", "{F6A7B8C9-D0E1-4F5A-3B4C-5D6E7F8A9B0C}"
	ProjectSection(SolutionItems) = preProject
		.dockerignore = .dockerignore
		.env.example = .env.example
		.gitignore = .gitignore
		ARCHITECTURE.md = ARCHITECTURE.md
		CONSUMABLE_NORMALIZATION.md = CONSUMABLE_NORMALIZATION.md
		COSMOS_DB_SETUP.md = COSMOS_DB_SETUP.md
		COSMOS_MIGRATION_SUMMARY.md = COSMOS_MIGRATION_SUMMARY.md
		DEPLOYMENT_GUIDE.md = DEPLOYMENT_GUIDE.md
		docker-compose.yml = docker-compose.yml
		Dockerfile = Dockerfile
		DOCKER_README.md = DOCKER_README.md
		DOCKER_VS_KUBERNETES.md = DOCKER_VS_KUBERNETES.md
		GITIGNORE_ADDITIONS.txt = GITIGNORE_ADDITIONS.txt
		KUBERNETES_README.md = KUBERNETES_README.md
		KUBERNETES_QUICK_REFERENCE.md = KUBERNETES_QUICK_REFERENCE.md
		Makefile = Makefile
		MIGRATION_SUMMARY.md = MIGRATION_SUMMARY.md
		PROJECT_STRUCTURE.md = PROJECT_STRUCTURE.md
		QUICK_START.md = QUICK_START.md
		README.md = README.md
		start-cosmos-emulator.ps1 = start-cosmos-emulator.ps1
		start-cosmos-docker.ps1 = start-cosmos-docker.ps1
	EndProjectSection
EndProject
Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "Deployment Scripts", "Deployment Scripts", "{A7B8C9D0-E1F2-4A5B-3C4D-5E6F7A8B9C0D}"
	ProjectSection(SolutionItems) = preProject
		cleanup-minikube.ps1 = cleanup-minikube.ps1
		cleanup-minikube.sh = cleanup-minikube.sh
		deploy-minikube.ps1 = deploy-minikube.ps1
		deploy-minikube.sh = deploy-minikube.sh
	EndProjectSection
EndProject
Project("{2150E333-8FDC-42A3-9474-1A3956D46DE8}") = "k8s", "k8s", "{B8C9D0E1-F2A3-4B5C-4D5E-6F7A8B9C0D1E}"
	ProjectSection(SolutionItems) = preProject
		k8s\app-configmap.yaml = k8s\app-configmap.yaml
		k8s\app-secret.yaml = k8s\app-secret.yaml
		k8s\ingress.yaml = k8s\ingress.yaml
		k8s\kustomization.yaml = k8s\kustomization.yaml
		k8s\mysql-deployment.yaml = k8s\mysql-deployment.yaml
		k8s\mysql-pvc.yaml = k8s\mysql-pvc.yaml
		k8s\mysql-secret.yaml = k8s\mysql-secret.yaml
		k8s\mysql-service.yaml = k8s\mysql-service.yaml
		k8s\namespace.yaml = k8s\namespace.yaml
		k8s\webapp-deployment.yaml = k8s\webapp-deployment.yaml
		k8s\webapp-service.yaml = k8s\webapp-service.yaml
	EndProjectSection
EndProject
Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Any CPU = Debug|Any CPU
		Release|Any CPU = Release|Any CPU
	EndGlobalSection
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D}.Release|Any CPU.Build.0 = Release|Any CPU
		{B2C3D4E5-F6A7-4B5C-9D0E-1F2A3B4C5D6E}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{B2C3D4E5-F6A7-4B5C-9D0E-1F2A3B4C5D6E}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{B2C3D4E5-F6A7-4B5C-9D0E-1F2A3B4C5D6E}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{B2C3D4E5-F6A7-4B5C-9D0E-1F2A3B4C5D6E}.Release|Any CPU.Build.0 = Release|Any CPU
		{C3D4E5F6-A7B8-4C5D-0E1F-2A3B4C5D6E7F}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{C3D4E5F6-A7B8-4C5D-0E1F-2A3B4C5D6E7F}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{C3D4E5F6-A7B8-4C5D-0E1F-2A3B4C5D6E7F}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{C3D4E5F6-A7B8-4C5D-0E1F-2A3B4C5D6E7F}.Release|Any CPU.Build.0 = Release|Any CPU
		{D4E5F6A7-B8C9-4D5E-1F2A-3B4C5D6E7F8A}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{D4E5F6A7-B8C9-4D5E-1F2A-3B4C5D6E7F8A}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{D4E5F6A7-B8C9-4D5E-1F2A-3B4C5D6E7F8A}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{D4E5F6A7-B8C9-4D5E-1F2A-3B4C5D6E7F8A}.Release|Any CPU.Build.0 = Release|Any CPU
		{E5F6A7B8-C9D0-4E5F-2A3B-4C5D6E7F8A9B}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{E5F6A7B8-C9D0-4E5F-2A3B-4C5D6E7F8A9B}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{E5F6A7B8-C9D0-4E5F-2A3B-4C5D6E7F8A9B}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{E5F6A7B8-C9D0-4E5F-2A3B-4C5D6E7F8A9B}.Release|Any CPU.Build.0 = Release|Any CPU
	EndGlobalSection
	GlobalSection(SolutionProperties) = preSolution
		HideSolutionNode = FALSE
	EndGlobalSection
	GlobalSection(NestedProjects) = preSolution
		{A7B8C9D0-E1F2-4A5B-3C4D-5E6F7A8B9C0D} = {F6A7B8C9-D0E1-4F5A-3B4C-5D6E7F8A9B0C}
		{B8C9D0E1-F2A3-4B5C-4D5E-6F7A8B9C0D1E} = {F6A7B8C9-D0E1-4F5A-3B4C-5D6E7F8A9B0C}
	EndGlobalSection
	GlobalSection(ExtensibilityGlobals) = postSolution
		SolutionGuid = {12345678-1234-1234-1234-123456789ABC}
	EndGlobalSection
EndGlobal
"@

# Write the updated solution file
Set-Content -Path $solutionPath -Value $solutionContent -Encoding UTF8

Write-Host ""
Write-Host "? Solution file updated successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Added to solution:" -ForegroundColor Cyan
Write-Host "  ?? Solution Items folder (updated):" -ForegroundColor Yellow
Write-Host "     - All documentation files (*.md)" -ForegroundColor White
Write-Host "     - Docker files (Dockerfile, docker-compose.yml, etc.)" -ForegroundColor White
Write-Host "     - Makefile" -ForegroundColor White
Write-Host ""
Write-Host "  ?? Deployment Scripts folder (new):" -ForegroundColor Yellow
Write-Host "     - deploy-minikube.sh" -ForegroundColor White
Write-Host "     - deploy-minikube.ps1" -ForegroundColor White
Write-Host "     - cleanup-minikube.sh" -ForegroundColor White
Write-Host "     - cleanup-minikube.ps1" -ForegroundColor White
Write-Host ""
Write-Host "  ?? k8s folder (new):" -ForegroundColor Yellow
Write-Host "     - namespace.yaml" -ForegroundColor White
Write-Host "     - mysql-secret.yaml" -ForegroundColor White
Write-Host "     - mysql-deployment.yaml" -ForegroundColor White
Write-Host "     - mysql-service.yaml" -ForegroundColor White
Write-Host "     - mysql-pvc.yaml" -ForegroundColor White
Write-Host "     - app-secret.yaml" -ForegroundColor White
Write-Host "     - app-configmap.yaml" -ForegroundColor White
Write-Host "     - webapp-deployment.yaml" -ForegroundColor White
Write-Host "     - webapp-service.yaml" -ForegroundColor White
Write-Host "     - ingress.yaml" -ForegroundColor White
Write-Host "     - kustomization.yaml" -ForegroundColor White
Write-Host ""
Write-Host "You can now reopen Visual Studio and see all files in Solution Explorer!" -ForegroundColor Green
Write-Host ""
Write-Host "Note: A backup was created at HappyLife.sln.backup" -ForegroundColor Gray
