function Test-UpdatingPackageInProjectDoesntRemoveFromSolutionIfInUse {
    # Arrange
    $p1 = New-WebApplication
    $p2 = New-ClassLibrary 

    $oldReferences = @("Castle.Core", 
                       "Castle.Services.Logging.log4netIntegration", 
                       "Castle.Services.Logging.NLogIntegration", 
                       "log4net",
                       "NLog")
                       
    Install-Package Castle.Core -Version 1.2.0 -Project $p1.Name
    $oldReferences | %{ Assert-Reference $p1 $_ }
    
    Install-Package Castle.Core -Version 1.2.0 -Project $p2.Name
    $oldReferences | %{ Assert-Reference $p2 $_ }
    
    # Check that it's installed at solution level
    Assert-SolutionPackage Castle.Core 1.2.0
    
    # Update the package in the first project
    Update-Package Castle.Core -Project $p1.Name -Version 2.5.1
    Assert-Reference $p1 Castle.Core 2.5.1.0
    Assert-SolutionPackage Castle.Core 2.5.1
    Assert-SolutionPackage Castle.Core 1.2.0
    
    # Update the package in the second project
    Update-Package Castle.Core -Project $p2.Name -Version 2.5.1
    Assert-Reference $p2 Castle.Core 2.5.1.0
    
    # Make sure that the old one is removed since no one is using it
    Assert-Null (Get-SolutionPackage Castle.Core 1.2.0)
}

function Test-UpdatingPackageWithSharedDependency {
    param(
        $context
    )
    
    # Arrange
    $p = New-ClassLibrary

    # Act
    Install-Package D -Version 1.0 -Source $context.RepositoryPath
    Assert-Package $p D 1.0
    Assert-Package $p B 1.0
    Assert-Package $p C 1.0
    Assert-Package $p A 2.0
    Assert-SolutionPackage D 1.0
    Assert-SolutionPackage B 1.0
    Assert-SolutionPackage C 1.0
    Assert-SolutionPackage A 2.0
    Assert-Null (Get-SolutionPackage A 1.0)
    
    Update-Package D -Source $context.RepositoryPath
    # Make sure the new package is installed
    Assert-Package $p D 2.0
    Assert-Package $p B 2.0
    Assert-Package $p C 2.0
    Assert-Package $p A 3.0
    Assert-SolutionPackage D 2.0
    Assert-SolutionPackage B 2.0
    Assert-SolutionPackage C 2.0
    Assert-SolutionPackage A 3.0
    
    # Make sure the old package is removed
    Assert-Null (Get-ProjectPackage $p D 1.0)
    Assert-Null (Get-ProjectPackage $p B 1.0)
    Assert-Null (Get-ProjectPackage $p C 1.0)
    Assert-Null (Get-ProjectPackage $p A 2.0)
    Assert-Null (Get-SolutionPackage D 1.0)
    Assert-Null (Get-SolutionPackage B 1.0)
    Assert-Null (Get-SolutionPackage C 1.0)
    Assert-Null (Get-SolutionPackage A 2.0)
}