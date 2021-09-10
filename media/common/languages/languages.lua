gge_include `/common/languages/english.lua`
gge_include `/common/languages/french.lua`

language = languageEnglish

languages_table = { ["English"]=languageEnglish, ["French"]=languageFrench }

getlanguage = function(lang)
   return languages_table[lang]
end

gettext = function(str,...)
     if #{...} == 0 then
		  if language ~= nil then
		     if language[str] ~= nil then
		       return language[str]
		     end
		  end
     else
        gge_print(select(1,...))
        return language[select(1, ...)]
     end
     return str
end
