
# Do not remove - Some underlying powershell calls revert this setting
$ErrorActionPreference = "Stop"

azcopy cp "https://cidsaappstscannernuget.blob.core.windows.net/releases/?sv=2017-07-29&sr=c&sig=6qRnFQ5S25IT0q8pf4z1mPGKXMrfBctSe3TJ3Bt%2BtQQ%3D&st=2020-03-17T12%3A07%3A03Z&se=2020-04-17T12%3A07%3A03Z&sp=rwl" "D:\a\1\s\scanner" --recursive=true