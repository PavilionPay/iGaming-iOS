
echo "Building out custom EnvironmentVariables.plist..."
plutil -replace RedirectUri -string "$RedirectUri" $APPCENTER_SOURCE_DIRECTORY/iGamingDemo/BuildEnvironmentVariables.plist
plutil -replace BaseUri -string "$BaseUri" $APPCENTER_SOURCE_DIRECTORY/iGamingDemo/BuildEnvironmentVariables.plist
plutil -replace Audience -string "$Audience" $APPCENTER_SOURCE_DIRECTORY/iGamingDemo/BuildEnvironmentVariables.plist
plutil -replace Issuer -string "$Issuer" $APPCENTER_SOURCE_DIRECTORY/iGamingDemo/BuildEnvironmentVariables.plist
plutil -replace Secret -string "$Secret" $APPCENTER_SOURCE_DIRECTORY/iGamingDemo/BuildEnvironmentVariables.plist

plutil -p $APPCENTER_SOURCE_DIRECTORY/iGamingDemo/BuildEnvironmentVariables.plist

