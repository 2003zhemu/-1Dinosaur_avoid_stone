
:: 生成配置文件clea
:: 工具: \Tools\LuBan.ClientServer
:: 项目地址: https://github.com/focus-creative-games/luban
:: 帮助文档: https://focus-creative-games.github.io/luban/generate_code_data/#%E6%94%AF%E6%8C%81%E7%9A%84%E5%B9%B3%E5%8F%B0%E3%80%81%E5%BC%95%E6%93%8E%E5%92%8C%E8%AF%AD%E8%A8%80

set WORKSPACE=%cd%\configs\
set PROJECT=%cd%\
set GEN_CLIENT=%cd%\node_modules\wdm.luban\src\Luban.ClientServer\bin\Release\net6.0\Luban.ClientServer.exe
set CONF_ROOT=%WORKSPACE%\
set CSHARP_CODE_DIR=%PROJECT%\c2l_projects\wdm.WuKong.Configs\src\Datas
set LUA_CODE_DIR=%PROJECT%\_genConfigs\lua
set OUT_DATA_DIR=%PROJECT%\_genConfigs
set OUT_JSON_DIR=%PROJECT%\_genConfigs_json

:: 进入配置目录
cd %WORKSPACE%
:: 生成csharp代码和lua配置
%GEN_CLIENT% -j cfg --^
 -d %CONF_ROOT%\__root__.xml ^
 --input_data_dir %CONF_ROOT% ^
 --output_code_dir %CSHARP_CODE_DIR% ^
 --output_data_dir %OUT_DATA_DIR% ^
 --gen_types data_lua,data_json ^
 -s all 
