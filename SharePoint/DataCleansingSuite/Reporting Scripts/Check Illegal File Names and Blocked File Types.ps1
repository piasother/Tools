
#----------------------------------------------------------------------------------------------------Dialog Box 1 - Folder To be Searched
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

[array]$DropDownArray = "DirectoryName","Name","Length","LastWriteTime" #----------------------------The Group By Array

#----------------------------------------------------------------------------------------------------This Function Returns the Selected Value and Closes the Form

function Return-DropDown {

	$Choice = $DropDown.SelectedItem.ToString()
	$Form.Close()
	Write-Host $Choice

}

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Select Folder to Check"
$objForm.Size = New-Object System.Drawing.Size(290,300) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$x=$objTextBox.Text;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})

$DropDownLabel = new-object System.Windows.Forms.Label
$DropDownLabel.Location = new-object System.Drawing.Size(10,140)
$DropDownLabel.size = new-object System.Drawing.Size(280,30)
$DropDownLabel.Text = "Select how you want the report to be grouped"
$objform.Controls.Add($DropDownLabel)
    
$DropDown = new-object System.Windows.Forms.ComboBox
$DropDown.Location = new-object System.Drawing.Size(10,170)
$DropDown.Size = new-object System.Drawing.Size(260,20)

ForEach ($Item in $DropDownArray) {
	$DropDown.Items.Add($Item)
}

$objform.Controls.Add($DropDown)    


$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,230)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$DirectoryToSearch=$objTextBox.Text;$GroupBy=$DropDown.Text;$objForm.Close()})

$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,230)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,10) 
$objLabel.Size = New-Object System.Drawing.Size(280,40) 
$objLabel.Text = "Please enter the name of the directory you want to Search for illegal SharePoint Filenames"
$objForm.Controls.Add($objLabel) 

$objLabel1 = New-Object System.Windows.Forms.Label
$objLabel1.Location = New-Object System.Drawing.Size(10,80) 
$objLabel1.Size = New-Object System.Drawing.Size(280,40) 
$objLabel1.Text = "Please ensure you use the following format c:\Name\Name or \\name\name"
$objForm.Controls.Add($objLabel1) 

$objTextBox = New-Object System.Windows.Forms.TextBox 
$objTextBox.Location = New-Object System.Drawing.Size(10,50) 
$objTextBox.Size = New-Object System.Drawing.Size(260,20) 
$objForm.Controls.Add($objTextBox) 

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})

[void] $objForm.ShowDialog()

$DirectoryToSearch
$GroupBy

#----------------------------------------------------------------------------------------------------Create Output Folder and Date Stamped File name
[IO.Directory]::CreateDirectory("c:\SundownSolutions")

$Date = Get-Date
$Filename="BothReports{0:d2}{1:d2}{2:d2}-{3:d2}{4:d2}.txt" -f $date.day,$date.month,$date.year,$date.hour,$date.minute
$Filename2 = "c:\SundownSolutions\" + $Filename

#----------------------------------------------------------------------------------------------------Conduct The Search and Output the File

$File = Get-ChildItem $DirectoryToSearch -include '*&*','*#*','*%*','*{*','*}*','*~*','*..*','*...*',*.ade,*.adp,*.app,*.asa,*.ashx,*.asmx,*.asp,*.bas,*.bat,*.cdx,*.cer,*.chm,*.class,*.cmd,*.cnt,*.com,*.config,*.cpl,*.crt,*.csh,*.der,*.dll,*.exe,*.fxp,*.gadget,*.grp,*.hlp,*.hpj,*.hta,*.htr,*.htw,*.ida,*.idc,*.idq,*.ins,*.isp,*.its,*.jse,*.ksh,*.lnk,*.mad,*.maf,*.mag,*.mam,*.maq,*.mar,*.mas,*.mat,*.mau,*.mav,*.maw,*.mcf,*.mda,*.mdb,*.mde,*.mdt,*.mdw,*.mdz,*.msc,*.msh,*.msh1,*.msh1xml,*.msh2,*.msh2xml,*.mshxml,*.msi,*.msp,*.mst,*.ops,*.pcd,*.pif,*.pl,*.prf,*.prg,*.printer,*.ps1,*.ps1xml,*.ps2,*.ps2xml,*.psc1,*.psc2,*.pst,*.reg,*.rem,*.scf,*.scr,*.sct,*.shb,*.shs,*.shtm,*.shtml,*.soap,*.stm,*.svc,*.url,*.vb,*.vbe,*.vbs,*.ws,*.wsc,*.wsf,*.wsh -recurse | Sort-Object -property $GroupBy | format-table -property Name, DirectoryName, LastWriteTime, Length -groupby $GroupBy | Out-File $Filename2 -width 180

$File

#----------------------------------------------------------------------------------------------------Open File in IE

$ie = new-object -comobject "InternetExplorer.Application"
$ie.visible = $true
$ie.navigate($Filename2)

#----------------------------------------------------------------------------------------------------Dispose of all variables - Cleaning up :)

function Dispose-All {
  Get-Variable -exclude Runspace |
       Where-Object {
           $_.Value -is [System.IDisposable]
       } |
       Foreach-Object {
           $_.Value.Dispose()
           Remove-Variable $_.Name
       }
}

