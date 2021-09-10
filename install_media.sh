# bash install_in_media.sh
# install bare minium media with editor
cp Normal/engine/engine.exe media/Grit.dat
cp Normal/launcher/launcher.exe media/Grit.exe
cp Normal/extract/extract.exe media/Tools
cp Normal/GritXMLConverter/GritXMLConverter.exe media/Tools
cd media
git svn fetch --ignore-paths https://svn.code.sf.net/p/gritengine/code/trunk/cg.dll
git svn fetch --ignore-paths https://svn.code.sf.net/p/gritengine/code/trunk/icuin42.dll
git svn fetch --ignore-paths https://svn.code.sf.net/p/gritengine/code/trunk/icuuc42.dll
git svn fetch --ignore-paths https://svn.code.sf.net/p/gritengine/code/trunk/OpenAL32.dll
