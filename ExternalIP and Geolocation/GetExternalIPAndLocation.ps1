# *************************************************************************************************************************************************
# Script: GetExternalIPAndLocation.ps1
# Version: 1.00
# Author: Marc-Andre Tanguay
# Description: This script when run on a local computer will clear the root\cimv2\nable\GEOLOCATION class, or create it 
#              if it doesnt exist, then will poll the freegeoip.com website, and will return general geolocation for the IP addres
# Date: Sept 4, 2012
# *************************************************************************************************************************************************




# Version History

# 1.00 - Initial Version. returns 8 data points (countryname,countrycode,regionname,regioncode,city,externalip,latitude,longitude)







$ns=[wmiclass]'__namespace'
$sc=$ns.CreateInstance()
$sc.Name='nable'
$sc.Put()
$file="c:\temp\file1.txt"

if ((get-wmiobject -namespace "root/cimv2/nable" -list -EV namespaceError) | ? {$_.name -match "GEOLOCATION"})
{
   
    $dbcount = New-Object system.Collections.ArrayList
    $testfolder=Get-WMIObject -namespace root/cimv2/nable -query "Select * From GEOLOCATION"
    $rr=0;
    Get-WMIObject -namespace root/cimv2/nable -query "Select * From GEOLOCATION" | foreach {$dbcount.Insert($rr, $_);$rr++ }

    $dbcnt=$dbcount.count
    if($dbcount.count -ge '1')
    {
        $testfolder | Remove-WMIObject
    }  

}
else
{
    

    if( ![string]::IsNullOrEmpty( $namespaceError[0] ) )
    {
    	add-content $file "ERROR accessing namespace: $namespaceError[0]"
    	RETURN
    }

    try 
    {

    $newClass = New-Object System.Management.ManagementClass `
        ("root\cimv2\nable", [String]::Empty, $null); 
        $newClass["__CLASS"] = "GEOLOCATION"; 

    $newClass.Qualifiers.Add("Static", $true)
	$newClass.Properties.Add("ExternalIP", [System.Management.CimType]::String, $false)
    $newClass.Properties["ExternalIP"].Qualifiers.Add("Key", $true)
	
    $newClass.Qualifiers.Add("Static", $true)
	$newClass.Properties.Add("CountryName", [System.Management.CimType]::String, $false)
    $newClass.Properties["CountryName"].Qualifiers.Add("Key", $true)

    $newClass.Qualifiers.Add("Static", $true)
	$newClass.Properties.Add("CountryCode", [System.Management.CimType]::String, $false)
    $newClass.Properties["CountryCode"].Qualifiers.Add("Key", $true)
	
        $newClass.Qualifiers.Add("Static", $true)
	$newClass.Properties.Add("RegionName", [System.Management.CimType]::String, $false)
    $newClass.Properties["RegionName"].Qualifiers.Add("Key", $true)
	
    $newClass.Qualifiers.Add("Static", $true)
	$newClass.Properties.Add("City", [System.Management.CimType]::String, $false)
    $newClass.Properties["City"].Qualifiers.Add("Key", $true)
	
    $newClass.Qualifiers.Add("Static", $true)
	$newClass.Properties.Add("Latitude", [System.Management.CimType]::String, $false)
    $newClass.Properties["Latitude"].Qualifiers.Add("Key", $true)
	
    $newClass.Qualifiers.Add("Static", $true)
	$newClass.Properties.Add("Longitude", [System.Management.CimType]::String, $false)
    $newClass.Properties["Longitude"].Qualifiers.Add("Key", $true)
	
    $newClass.Qualifiers.Add("Static", $true)
	$newClass.Properties.Add("RegionCode", [System.Management.CimType]::String, $false)
    $newClass.Properties["RegionCode"].Qualifiers.Add("Key", $true)
	
    $newClass.Put()
    }
    catch
    {
       add-content $file "ERROR creating WMI class: $_"
    }
    ######################################
}


	$webClient1 = New-Object System.Net.WebClient
	# Returns the public IP address
    $StringURL="http://freegeoip.net/xml/" 
	$StringVal = $webClient1.DownloadString($StringURL)
 
    
    $StringXML=[XML]$StringVal
#    $StringXML.Response.City
#    $StringXML.Response.Ip
#    $StringXML.Response.CountryName
#    $StringXML.Response.Longitude
#    $StringXML.Response.Latitude
 

try 
{
    $mb = ([wmiclass]"root/cimv2/nable:GEOLOCATION").CreateInstance()

    if ($StringXML.Response.Ip)
    {
        $mb.ExternalIP =  $StringXML.Response.Ip
    }
    else
    {
        $mb.ExternalIP =  "N/A"
    }
    if ($StringXML.Response.CountryName)
    {
        $mb.CountryName =  $StringXML.Response.CountryName
    }
    else
    {
        $mb.CountryName =  "N/A"
    }
    if ($StringXML.Response.CountryCode)
    {
        $mb.CountryCode =  $StringXML.Response.CountryCode
    }
    else
    {
        $mb.CountryCode =  "N/A"
    }
    if ($StringXML.Response.RegionName)
    {
        $mb.RegionName =  $StringXML.Response.RegionName
    }
    else
    {
        $mb.RegionName =  "N/A"
    }
    if ($StringXML.Response.City)
    {
        $mb.City =  $StringXML.Response.City
    }
    else
    {
        $mb.City =  "N/A"
    }
    if ($StringXML.Response.Latitude)
    {
        $mb.Latitude =  [Double]$StringXML.Response.Latitude
    }
    else
    {
        $mb.Latitude =  "0"
    }
    if ($StringXML.Response.Longitude)
    {
        $mb.Longitude =  [Double]$StringXML.Response.Longitude
    }
    else
    {
        $mb.Longitude =  "0"
    }
    if ($StringXML.Response.RegionCode)
    {
        $mb.RegionCode =  $StringXML.Response.RegionCode
    }
    else
    {
        $mb.RegionCode =  "N/A"
    }
    

    $mb.Put() 
}
catch
{
    add-content $file "ERROR creating a new instance: $_"
}
  
   