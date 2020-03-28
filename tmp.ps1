remove-module psgistmanager
import-module .\PSGistManager.psd1
$g = Find-GHGist -SearchString "Windows Terminal"
