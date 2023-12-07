
echo "Building out custom BuildEnvironmentVariables.plist..."
plutil -replace RedirectUri -string "$RedirectUri" $APPCENTER_SOURCE_DIRECTORY/iGamingDemo/iGamingDemo/BuildEnvironmentVariables.plist
plutil -replace BaseUri     -string "$BaseUri"     $APPCENTER_SOURCE_DIRECTORY/iGamingDemo/iGamingDemo/BuildEnvironmentVariables.plist
plutil -replace Audience    -string "$Audience"    $APPCENTER_SOURCE_DIRECTORY/iGamingDemo/iGamingDemo/BuildEnvironmentVariables.plist
plutil -replace Issuer      -string "$Issuer"      $APPCENTER_SOURCE_DIRECTORY/iGamingDemo/iGamingDemo/BuildEnvironmentVariables.plist
plutil -replace Secret      -string "$Secret"      $APPCENTER_SOURCE_DIRECTORY/iGamingDemo/iGamingDemo/BuildEnvironmentVariables.plist

# Append to the "AssociatedDomains" array in the bundle plist
plutil -insert AssociatedDomains -string "$AssociatedDomain" -append $APPCENTER_SOURCE_DIRECTORY/iGamingDemo/iGamingDemo/BuildEnvironmentVariables.plist

plutil -p $APPCENTER_SOURCE_DIRECTORY/iGamingDemo/iGamingDemo/BuildEnvironmentVariables.plist

