# Use Windows PowerShell
# this will install bare minium media with editor
cp Normal/engine/engine.exe media/Grit.dat
cp Normal/launcher/launcher.exe media/Grit.exe
cp Normal/extract/extract.exe media/Tools
cp Normal/GritXMLConverter/GritXMLConverter.exe media/Tools
cd media
wget https://svn.code.sf.net/p/gritengine/code/trunk/ -OutFile cg.dll
wget https://svn.code.sf.net/p/gritengine/code/trunk/ -OutFile icuin42.dll
wget https://svn.code.sf.net/p/gritengine/code/trunk/ -OutFile icuuc42.dll
wget https://svn.code.sf.net/p/gritengine/code/trunk/ -OutFile OpenAL32.dll
