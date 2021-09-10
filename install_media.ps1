# This script will install a bare minium media directory with the editor inside your git grit-engine fork repository
# Open a Windows PowerShell
# Go inside your git fork grit-engine repository
# cd /d/Projects/Grit/grit-complement
# powershell -ExecutionPolicy Bypass -File install_media.ps1

# Open normal Windows command shell
# cd d:\Projects\Grit\grit-complement\media
# grit.exe
# Autorize grit.dat

cp Normal/engine/engine.exe media/Grit.dat
cp Normal/launcher/launcher.exe media/Grit.exe
cp Normal/extract/extract.exe media/Tools
cp Normal/GritXMLConverter/GritXMLConverter.exe media/Tools
cd media

wget "https://svn.code.sf.net/p/gritengine/code/trunk/cg.dll" -outfile "cg.dll"
wget "https://svn.code.sf.net/p/gritengine/code/trunk/icuin42.dll" -outfile "icuin42.dll"
wget "https://svn.code.sf.net/p/gritengine/code/trunk/icuuc42.dll" -outfile "icuuc42.dll"
wget "https://svn.code.sf.net/p/gritengine/code/trunk/icudt42.dll" -outfile "icudt42.dll"
wget "https://svn.code.sf.net/p/gritengine/code/trunk/OpenAL32.dll" -outfile "OpenAL32.dll"
