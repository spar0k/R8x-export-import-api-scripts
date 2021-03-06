#!/bin/bash
#
# SCRIPT Template for CLI Operations for command line parameters handling
#
# (C) 2016-2020 Eric James Beasley, @mybasementcloud, https://github.com/mybasementcloud/R8x-export-import-api-scripts
#
# ALL SCRIPTS ARE PROVIDED AS IS WITHOUT EXPRESS OR IMPLIED WARRANTY OF FUNCTION OR POTENTIAL FOR 
# DAMAGE Or ABUSE.  AUTHOR DOES NOT ACCEPT ANY RESPONSIBILITY FOR THE USE OF THESE SCRIPTS OR THE 
# RESULTS OF USING THESE SCRIPTS.  USING THESE SCRIPTS STIPULATES A CLEAR UNDERSTANDING OF RESPECTIVE
# TECHNOLOGIES AND UNDERLYING PROGRAMMING CONCEPTS AND STRUCTURES AND IMPLIES CORRECT IMPLEMENTATION
# OF RESPECTIVE BASELINE TECHNOLOGIES FOR PLATFORM UTILIZING THE SCRIPTS.  THIRD PARTY LIMITATIONS
# APPLY WITHIN THE SPECIFICS THEIR RESPECTIVE UTILIZATION AGREEMENTS AND LICENSES.  AUTHOR DOES NOT
# AUTHORIZE RESALE, LEASE, OR CHARGE FOR UTILIZATION OF THESE SCRIPTS BY ANY THIRD PARTY.
#
#
ScriptVersion=00.40.00
ScriptRevision=000
ScriptDate=2020-02-07
TemplateVersion=00.40.00
CommonScriptsVersion=00.40.00
CommonScriptsRevision=006

#

export APICommonActionsScriptVersion=v${ScriptVersion//./x}
export APICommonActionScriptTemplateVersion=v${TemplateVersion//./x}
ActionScriptName=identify_gaia_and_installation.action.common.$CommonScriptsRevision.v$ScriptVersion

# =================================================================================================
# Validate Common Actions Script version is correct for caller
# =================================================================================================


if [ x"$APIExpectedCommonScriptsVersion" = x"$APICommonActionsScriptVersion" ] ; then
    # Script and Common Actions Script versions match, go ahead
    echo >> $APICLIlogfilepath
    echo 'Verify Common Actions Scripts Version - OK' >> $APICLIlogfilepath
    echo >> $APICLIlogfilepath
else
    # Script and Actions Script versions don't match, ALL STOP!
    echo | tee -a -i $APICLIlogfilepath
    echo 'Verify Common Actions Scripts Version - Missmatch' | tee -a -i $APICLIlogfilepath
    echo 'Expected Common Script version : '$APIExpectedCommonScriptsVersion | tee -a -i $APICLIlogfilepath
    echo 'Current  Common Script version : '$APICommonActionsScriptVersion | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    echo 'Critical Error - Exiting Script !!!!' | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    echo "Log output in file $APICLIlogfilepath" | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath

    exit 250
fi


# =================================================================================================
# =================================================================================================
# START:  Determine version of server and type
# =================================================================================================


if [ "$APISCRIPTVERBOSE" = "true" ] ; then
    echo | tee -a -i $APICLIlogfilepath
    echo 'ActionScriptName:  '$ActionScriptName'  Script Version: '$ScriptVersion'  Revision:  '$ScriptRevision | tee -a -i $APICLIlogfilepath
else
    echo >> $APICLIlogfilepath
    echo 'ActionScriptName:  '$ActionScriptName'  Script Version: '$ScriptVersion'  Revision:  '$ScriptRevision >> $APICLIlogfilepath
fi


# -------------------------------------------------------------------------------------------------
# Handle important basics
# -------------------------------------------------------------------------------------------------


# =================================================================================================
# START:  Local Variables
# =================================================================================================


export APICLIActionstemplogfilepath=/var/tmp/$ScriptName'_'$APIScriptVersion'_temp_'$DATEDTGS.log


# =================================================================================================
# START:  Local Proceedures
# =================================================================================================


# -------------------------------------------------------------------------------------------------
# CheckAndUnlockGaiaDB - Check and Unlock Gaia database
# -------------------------------------------------------------------------------------------------

# MODIFIED 2019-01-31 -\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

CheckAndUnlockGaiaDB () {
    #
    # CheckAndUnlockGaiaDB - Check and Unlock Gaia database
    #
    
    echo -n 'Unlock gaia database : '

    export gaiadbunlocked=false

    until $gaiadbunlocked ; do

        export checkgaiadblocked=`clish -i -c "lock database override" | grep -i "owned"`
        export isclishowned=`test -z $checkgaiadblocked; echo $?`

        if [ $isclishowned -eq 1 ]; then 
            echo -n '.'
            export gaiadbunlocked=false
        else
            echo -n '!'
            export gaiadbunlocked=true
        fi

    done

    echo; echo
    
    return 0
}

#
# \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-  MODIFIED 2019-01-31

#CheckAndUnlockGaiaDB

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------


# -------------------------------------------------------------------------------------------------
# SetupTempLogFile - Setup Temporary Log File and clear any debris
# -------------------------------------------------------------------------------------------------

# MODIFIED 2019-01-18 -\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

SetupTempLogFile () {
    #
    # SetupTempLogFile - Setup Temporary Log File and clear any debris
    #

    export APICLIActionstemplogfilepath=/var/tmp/$ScriptName'_'$APIScriptVersion'_temp_'$DATEDTGS.log

    rm $APICLIActionstemplogfilepath >> $APICLIlogfilepath 2> $APICLIlogfilepath

    touch $APICLIActionstemplogfilepath

    return 0
}

#
# \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-  MODIFIED 2019-01-18

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------


# -------------------------------------------------------------------------------------------------
# HandleShowTempLogFile - Handle Showing of Temporary Log File based on verbose setting
# -------------------------------------------------------------------------------------------------

# MODIFIED 2019-01-18 -\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

HandleShowTempLogFile () {
    #
    # HandleShowTempLogFile - Handle Showing of Temporary Log File based on verbose setting
    #

    if [ "$APISCRIPTVERBOSE" = "true" ] ; then
        # verbose mode so show the logged results and copy to normal log file
        cat $APICLIActionstemplogfilepath | tee -a -i $APICLIlogfilepath
    else
        # NOT verbose mode so push logged results to normal log file
        cat $APICLIActionstemplogfilepath >> $APICLIlogfilepath
    fi
    
    rm $APICLIActionstemplogfilepath >> $APICLIlogfilepath 2> $APICLIlogfilepath
    return 0
}

#
# \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-  MODIFIED 2019-01-18

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------


# -------------------------------------------------------------------------------------------------
# ForceShowTempLogFile - Handle Showing of Temporary Log File based forced display
# -------------------------------------------------------------------------------------------------

# MODIFIED 2019-01-18 -\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

ForceShowTempLogFile () {
    #
    # ForceShowTempLogFile - Handle Showing of Temporary Log File based forced display
    #

    cat $APICLIActionstemplogfilepath | tee -a -i $APICLIlogfilepath
    
    rm $APICLIActionstemplogfilepath >> $APICLIlogfilepath 2> $APICLIlogfilepath

    return 0
}

#
# \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-  MODIFIED 2019-01-18

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------


# -------------------------------------------------------------------------------------------------
# clishIndependentVersionCheck - Removing dependency on clish to avoid collissions when database is locked
# -------------------------------------------------------------------------------------------------

# MODIFIED 2019-05-31 -\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

clishIndependentVersionCheck () {
    #
    export productversion=$(clish -i -c "show version product" | cut -d " " -f 6)

    # Keep the first string before next space in returned product version, since that could be owned 
    # if clish is owned elsewhere
    #
    export gaiaversion=$(echo $productversion | cut -d " " -f 1)

    # check if clish is owned and if it is, try a different alternative to get the version
    #
    export checkgaiaversion=`echo "${gaiaversion}" | grep -i "owned"`
    export isclishowned=`test -z $checkgaiaversion; echo $?`
    if [ $isclishowned -eq 1 ]; then 
        cpreleasefile=/etc/cp-release
        if [ -r $cpreleasefile ] ; then
            # OK we have the easy-button alternative
            export gaiaversion=$(cat $cpreleasefile | cut -d " " -f 4)
        else
            # OK that's not going to work without the file

            # Requires that $JQ is properly defined in the script
            # so $UseJSONJQ = true must be set on template version 0.32.0 and higher
            #
            export pythonpath=$MDS_FWDIR/Python/bin/
            if $UseJSONJQ ; then
                export get_platform_release=`$pythonpath/python $MDS_FWDIR/scripts/get_platform.py -f json | $JQ '. | .release'`
            else
                export get_platform_release=`$pythonpath/python $MDS_FWDIR/scripts/get_platform.py -f json | ${CPDIR_PATH}/jq/jq '. | .release'`
            fi
            
            export platform_release=${get_platform_release//\"/}
            export get_platform_release_version=`echo ${get_platform_release//\"/} | cut -d " " -f 4`
            export platform_release_version=${get_platform_release_version//\"/}
            
            export gaiaversion=$platform_release_version
        fi
    fi
    return 0
}

#
# \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-  MODIFIED 2019-05-31

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

#clishIndependentVersionCheck


# -------------------------------------------------------------------------------------------------
# Start :  Determine version of server and type
# -------------------------------------------------------------------------------------------------


IdentifyGaiaVersionAndInstallationType () {
    #
    # Identify Gaia Version And Installation Type
    #
    
    #----------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------
    #
    # Gaia version and installation type identification
    #
    #----------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------
    

    export gaiaversionoutputfile=/var/tmp/gaiaversion_$DATEDTGS.txt

    # remove the file if it exists
    if [ -w $gaiaversionoutputfile ] ; then
        rm $gaiaversionoutputfile >> $APICLIlogfilepath 2> $APICLIlogfilepath
    fi
    
    touch $gaiaversionoutputfile >> $APICLIlogfilepath 2> $APICLIlogfilepath
    
    echo > $gaiaversionoutputfile
    
    # -------------------------------------------------------------------------------------------------
    # -------------------------------------------------------------------------------------------------
    # START: Identify Gaia Version and Installation Type Details
    # -------------------------------------------------------------------------------------------------
    
    clishIndependentVersionCheck    

    
    echo 'Gaia Version : $gaiaversion = '$gaiaversion >> $gaiaversionoutputfile
    echo >> $gaiaversionoutputfile
    
    # -------------------------------------------------------------------------------------------------
    # -------------------------------------------------------------------------------------------------
    
    
    export Check4SMS=0
    export Check4EPM=0
    export Check4MDS=0
    export Check4GW=0
    
    workfile=/var/tmp/cpinfo_ver.$DATEDTGS.txt
    cpinfo -y all > $workfile 2>&1

    Check4EP=`grep -c "Endpoint Security Management" $workfile`
    Check4EP773003=`grep -c "Endpoint Security Management R77.30.03 " $workfile`
    Check4EP773002=`grep -c "Endpoint Security Management R77.30.02 " $workfile`
    Check4EP773001=`grep -c "Endpoint Security Management R77.30.01 " $workfile`
    Check4EP773000=`grep -c "Endpoint Security Management R77.30 " $workfile`
    
    Check4SMS=`grep -c "Security Management Server" $workfile`
    Check4SMSR80x10=`grep -c "Security Management Server R80.10 " $workfile`
    Check4SMSR80x20=`grep -c "Security Management Server R80.20 " $workfile`
    Check4SMSR80x20xM1=`grep -c "Security Management Server R80.20.M1 " $workfile`
    Check4SMSR80x20xM2=`grep -c "Security Management Server R80.20.M2 " $workfile`
    Check4SMSR80x30=`grep -c "Security Management Server R80.30 " $workfile`
    Check4SMSR80x30xM1=`grep -c "Security Management Server R80.30.M1 " $workfile`
    Check4SMSR80x30xM2=`grep -c "Security Management Server R80.30.M2 " $workfile`
    Check4SMSR80x40=`grep -c "Security Management Server R80.40 " $workfile`
    Check4SMSR80x40xM1=`grep -c "Security Management Server R80.40.M1 " $workfile`
    Check4SMSR80x40xM2=`grep -c "Security Management Server R80.40.M2 " $workfile`
    rm $workfile
    
    if [ "$MDSDIR" != '' ]; then
        export Check4MDS=1
    else 
        export Check4MDS=0
    fi
    
    if [ $Check4SMS -gt 0 ] && [ $Check4MDS -gt 0 ]; then
        echo "System is Multi-Domain Management Server!" >> $gaiaversionoutputfile
        export Check4GW=0
    elif [ $Check4SMS -gt 0 ] && [ $Check4MDS -eq 0 ]; then
        echo "System is Security Management Server!" >> $gaiaversionoutputfile
        export Check4SMS=1
        export Check4GW=0
    else
        echo "System is a gateway!" >> $gaiaversionoutputfile
        export Check4GW=1
    fi
    echo >> $gaiaversionoutputfile
    
    if [ $Check4SMSR80x10 -gt 0 ]; then
        echo "Security Management Server version R80.10" >> $gaiaversionoutputfile
        #export gaiaversion=R80.10
        if [[ $($CPDIR/bin/cpprod_util UepmIsEps 2> /dev/null) == *"1"* ]]; then
        	export Check4EPM=1
            echo "Endpoint Security Server version R80.10" >> $gaiaversionoutputfile
        else
        	export Check4EPM=0
        fi
    elif [ $Check4SMSR80x20 -gt 0 ]; then
        echo "Security Management Server version R80.20" >> $gaiaversionoutputfile
        #export gaiaversion=R80.20
        if [[ $($CPDIR/bin/cpprod_util UepmIsEps 2> /dev/null) == *"1"* ]]; then
        	export Check4EPM=1
            echo "Endpoint Security Server version R80.20" >> $gaiaversionoutputfile
        else
        	export Check4EPM=0
        fi
    elif [ $Check4SMSR80x20xM1 -gt 0 ]; then
        echo "Security Management Server version R80.20.M1" >> $gaiaversionoutputfile
        #export gaiaversion=R80.20.M1
        if [[ $($CPDIR/bin/cpprod_util UepmIsEps 2> /dev/null) == *"1"* ]]; then
        	export Check4EPM=1
            echo "Endpoint Security Server version R80.20.M1" >> $gaiaversionoutputfile
        else
        	export Check4EPM=0
        fi
    elif [ $Check4SMSR80x20xM2 -gt 0 ]; then
        echo "Security Management Server version R80.20.M2" >> $gaiaversionoutputfile
        #export gaiaversion=R80.20.M2
        if [[ $($CPDIR/bin/cpprod_util UepmIsEps 2> /dev/null) == *"1"* ]]; then
        	export Check4EPM=1
            echo "Endpoint Security Server version R80.20.M2" >> $gaiaversionoutputfile
        else
        	export Check4EPM=0
        fi
    elif [ $Check4SMSR80x20xM3 -gt 0 ]; then
        echo "Security Management Server version R80.20.M3" >> $gaiaversionoutputfile
        #export gaiaversion=R80.20.M3
        if [[ $($CPDIR/bin/cpprod_util UepmIsEps 2> /dev/null) == *"1"* ]]; then
        	export Check4EPM=1
            echo "Endpoint Security Server version R80.20.M3" >> $gaiaversionoutputfile
        else
        	export Check4EPM=0
        fi
    elif [ $Check4SMSR80x30 -gt 0 ]; then
        echo "Security Management Server version R80.30" >> $gaiaversionoutputfile
        #export gaiaversion=R80.30
        if [[ $($CPDIR/bin/cpprod_util UepmIsEps 2> /dev/null) == *"1"* ]]; then
        	export Check4EPM=1
            echo "Endpoint Security Server version R80.30" >> $gaiaversionoutputfile
        else
        	export Check4EPM=0
        fi
    elif [ $Check4SMSR80x30xM1 -gt 0 ]; then
        echo "Security Management Server version R80.30.M1" >> $gaiaversionoutputfile
        #export gaiaversion=R80.30.M1
        if [[ $($CPDIR/bin/cpprod_util UepmIsEps 2> /dev/null) == *"1"* ]]; then
        	export Check4EPM=1
            echo "Endpoint Security Server version R80.30.M1" >> $gaiaversionoutputfile
        else
        	export Check4EPM=0
        fi
    elif [ $Check4SMSR80x30xM2 -gt 0 ]; then
        echo "Security Management Server version R80.30.M2" >> $gaiaversionoutputfile
        #export gaiaversion=R80.30.M2
        if [[ $($CPDIR/bin/cpprod_util UepmIsEps 2> /dev/null) == *"1"* ]]; then
        	Check4EPM=1
            echo "Endpoint Security Server version R80.30.M2" >> $gaiaversionoutputfile
        else
        	export Check4EPM=0
        fi
    elif [ $Check4SMSR80x40 -gt 0 ]; then
        echo "Security Management Server version R80.40" >> $gaiaversionoutputfile
        #export gaiaversion=R80.40
        if [[ $($CPDIR/bin/cpprod_util UepmIsEps 2> /dev/null) == *"1"* ]]; then
        	export Check4EPM=1
            echo "Endpoint Security Server version R80.40" >> $gaiaversionoutputfile
        else
        	export Check4EPM=0
        fi
    elif [ $Check4SMSR80x40xM1 -gt 0 ]; then
        echo "Security Management Server version R80.40.M1" >> $gaiaversionoutputfile
        #export gaiaversion=R80.40.M1
        if [[ $($CPDIR/bin/cpprod_util UepmIsEps 2> /dev/null) == *"1"* ]]; then
        	export Check4EPM=1
            echo "Endpoint Security Server version R80.40.M1" >> $gaiaversionoutputfile
        else
        	export Check4EPM=0
        fi
    elif [ $Check4SMSR80x40xM2 -gt 0 ]; then
        echo "Security Management Server version R80.40.M2" >> $gaiaversionoutputfile
        #export gaiaversion=R80.40.M2
        if [[ $($CPDIR/bin/cpprod_util UepmIsEps 2> /dev/null) == *"1"* ]]; then
        	Check4EPM=1
            echo "Endpoint Security Server version R80.40.M2" >> $gaiaversionoutputfile
        else
        	export Check4EPM=0
        fi
    elif [ $Check4EP773000 -gt 0 ] && [ $Check4EP773003 -gt 0 ]; then
        echo "Endpoint Security Server version R77.30.03" >> $gaiaversionoutputfile
        export gaiaversion=R77.30.03
        export Check4EPM=1
    elif [ $Check4EP773000 -gt 0 ] && [ $Check4EP773002 -gt 0 ]; then
        echo "Endpoint Security Server version R77.30.02" >> $gaiaversionoutputfile
        export gaiaversion=R77.30.02
        export Check4EPM=1
    elif [ $Check4EP773000 -gt 0 ] && [ $Check4EP773001 -gt 0 ]; then
        echo "Endpoint Security Server version R77.30.01" >> $gaiaversionoutputfile
        export gaiaversion=R77.30.01
        export Check4EPM=1
    elif [ $Check4EP773000 -gt 0 ]; then
        echo "Endpoint Security Server version R77.30" >> $gaiaversionoutputfile
        export gaiaversion=R77.30
        export Check4EPM=1
    else
        echo "Not Gaia Endpoint Security Server R77.30" >> $gaiaversionoutputfile
        
        if [[ $($CPDIR/bin/cpprod_util UepmIsEps 2> /dev/null) == *"1"* ]]; then
        	export Check4EPM=1
        else
        	export Check4EPM=0
        fi
        
    fi
    
    echo >> $gaiaversionoutputfile
    echo 'Final $gaiaversion = '$gaiaversion >> $gaiaversionoutputfile
    echo >> $gaiaversionoutputfile
    
    #if [ $Check4MDS -eq 1 ]; then
    #	echo 'Multi-Domain Management stuff...' >> $gaiaversionoutputfile
    #fi
    #
    #if [ $Check4SMS -eq 1 ]; then
    #	echo 'Security Management Server stuff...' >> $gaiaversionoutputfile
    #fi
    #
    #if [ $Check4EPM -eq 1 ]; then
    #	echo 'Endpoint Security Management Server stuff...' >> $gaiaversionoutputfile
    #fi
    #
    #if [ $Check4GW -eq 1 ]; then
    #	echo 'Gateway stuff...' >> $gaiaversionoutputfile
    #fi
    #echo >> $gaiaversionoutputfile
    #
    
    #export gaia_kernel_version=$(uname -r)
    #if [ "$gaia_kernel_version" == "2.6.18-92cpx86_64" ]; then
    #    echo "OLD Kernel version $gaia_kernel_version" >> $gaiaversionoutputfile
    #elif [ "$gaia_kernel_version" == "3.10.0-514cpx86_64" ]; then
    #    echo "NEW Kernel version $gaia_kernel_version" >> $gaiaversionoutputfile
    #else
    #    echo "Kernel version $gaia_kernel_version" >> $gaiaversionoutputfile
    #fi
    #echo >> $gaiaversionoutputfile
    #
    
    export gaia_kernel_version=$(uname -r)
    export kernelv2x06=2.6
    export kernelv3x10=3.10
    export checkthiskernel=`echo "${gaia_kernel_version}" | grep -i "$kernelv2x06"`
    export isitoldkernel=`test -z $checkthiskernel; echo $?`
    export checkthiskernel=`echo "${gaia_kernel_version}" | grep -i "$kernelv3x10"`
    export isitnewkernel=`test -z $checkthiskernel; echo $?`
    
    if [ $isitoldkernel -eq 1 ] ; then
        echo "OLD Kernel version $gaia_kernel_version" >> $gaiaversionoutputfile
    elif [ $isitnewkernel -eq 1 ]; then
        echo "NEW Kernel version $gaia_kernel_version" >> $gaiaversionoutputfile
    else
        echo "Kernel version $gaia_kernel_version" >> $gaiaversionoutputfile
    fi
    echo >> $gaiaversionoutputfile
    
    # Alternative approach from Health Check
    
    export sys_type="N/A"
    export sys_type_MDS=false
    export sys_type_SMS=false
    export sys_type_SmartEvent=false
    export sys_type_SmartEvent_CorrelationUnit=false
    export sys_type_GW=false
    export sys_type_STANDALONE=false
    export sys_type_VSX=false
    export sys_type_UEPM_Installed=false
    export sys_type_UEPM_EndpointServer=false
    export sys_type_UEPM_PolicyServer=false
    
    
    #  System Type
    if [[ $(echo $MDSDIR | grep mds) ]]; then
        export sys_type_MDS=true
        export sys_type_SMS=false
        export sys_type="MDS"
    elif [[ $($CPDIR/bin/cpprod_util FwIsFirewallMgmt 2> /dev/null) == *"1"*  ]]; then
        export sys_type_SMS=true
        export sys_type_MDS=false
        export sys_type="SMS"
    else
        export sys_type_SMS=false
        export sys_type_MDS=false
    fi
    
    # Updated to correctly identify if SmartEvent is active
    # $CPDIR/bin/cpprod_util RtIsRt -> returns wrong result for MDM
    # $CPDIR/bin/cpprod_util RtIsAnalyzerServer -> returns correct result for MDM
    
    if [[ $($CPDIR/bin/cpprod_util RtIsAnalyzerServer 2> /dev/null) == *"1"*  ]]; then
        export sys_type_SmartEvent=true
        export sys_type="SmartEvent"
    else
        export sys_type_SmartEvent=false
    fi
    
    if [[ $($CPDIR/bin/cpprod_util RtIsAnalyzerCorrelationUnit 2> /dev/null) == *"1"*  ]]; then
        export sys_type_SmartEvent_CorrelationUnit=true
    else
        export sys_type_SmartEvent_CorrelationUnit=false
    fi
    
    if [[ $($CPDIR/bin/cpprod_util FwIsVSX 2> /dev/null) == *"1"* ]]; then
    	export sys_type_VSX=true
    	export sys_type="VSX"
    else
    	export sys_type_VSX=false
    fi
    
    if [[ $($CPDIR/bin/cpprod_util FwIsFirewallModule 2> /dev/null) == *"1"*  ]]; then
        export sys_type_GW=true
        export sys_type="GATEWAY"
    else
        export sys_type_GW=false
    fi
    
    if [[ $($CPDIR/bin/cpprod_util FwIsStandAlone 2> /dev/null) == *"1"* ]]; then
        export sys_type_STANDALONE=true
        export sys_type="STANDALONE"
    else
        export sys_type_STANDALONE=false
    fi
    
    if [[ $($CPDIR/bin/cpprod_util UepmIsEps 2> /dev/null) == *"1"* ]]; then
    	export sys_type_UEPM_EndpointServer=true
    	export sys_type="UEPM"
    else
    	export sys_type_UEPM_EndpointServer=false
    fi
    
    if [[ $($CPDIR/bin/cpprod_util UepmIsPolicyServer 2> /dev/null) == *"1"* ]]; then
    	export sys_type_UEPM_PolicyServer=true
    else
    	export sys_type_UEPM_PolicyServer=false
    fi
    
    if [[ $($CPDIR/bin/cpprod_util UepmIsInstalled 2> /dev/null) == *"1"* ]]; then
    	export sys_type_UEPM_Installed=true
    else
    	export sys_type_UEPM_Installed=false
    fi
    
    echo "sys_type = "$sys_type >> $gaiaversionoutputfile
    
    echo >> $gaiaversionoutputfile
    echo "System Type : SMS                   :"$sys_type_SMS >> $gaiaversionoutputfile
    echo "System Type : MDS                   :"$sys_type_MDS >> $gaiaversionoutputfile
    echo "System Type : SmartEvent            :"$sys_type_SmartEvent >> $gaiaversionoutputfile
    echo "System Type : SmEv Correlation Unit :"$sys_type_SmartEvent_CorrelationUnit >> $gaiaversionoutputfile
    echo "System Type : GATEWAY               :"$sys_type_GW >> $gaiaversionoutputfile
    echo "System Type : STANDALONE            :"$sys_type_STANDALONE >> $gaiaversionoutputfile
    echo "System Type : VSX                   :"$sys_type_VSX >> $gaiaversionoutputfile
    echo "System Type : UEPM Endpoint Server  :"$sys_type_UEPM_EndpointServer >> $gaiaversionoutputfile
    echo "System Type : UEPM Policy Server    :"$sys_type_UEPM_PolicyServer >> $gaiaversionoutputfile
    echo "System Type : UEPM Installed        :"$sys_type_UEPM_Installed >> $gaiaversionoutputfile
    echo >> $gaiaversionoutputfile
    
    # -------------------------------------------------------------------------------------------------
    # END: Identify Gaia Version and Installation Type Details
    # -------------------------------------------------------------------------------------------------
    # -------------------------------------------------------------------------------------------------
    
    echo | tee -a -i $gaiaversionoutputfile

    return 0
}

#
# \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/-  MODIFIED 2019-05-31

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

#IdentifyGaiaVersionAndInstallationType


# =================================================================================================
# END:  Local Proceedures
# =================================================================================================


echo >> $APICLIlogfilepath
echo '-------------------------------------------------------------------------------------------------' >> $APICLIlogfilepath
echo '-------------------------------------------------------------------------------------------------' >> $APICLIlogfilepath
echo ' Identify Gaia Version and Installation Type Details ' >> $APICLIlogfilepath
echo '-------------------------------------------------------------------------------------------------' >> $APICLIlogfilepath
echo >> $APICLIlogfilepath

IdentifyGaiaVersionAndInstallationType "$@"

cat $gaiaversionoutputfile | tee -a -i $APICLIlogfilepath

echo >> $APICLIlogfilepath
echo '-------------------------------------------------------------------------------------------------' >> $APICLIlogfilepath
echo '-------------------------------------------------------------------------------------------------' >> $APICLIlogfilepath
echo >> $APICLIlogfilepath

rm $gaiaversionoutputfile

# -------------------------------------------------------------------------------------------------
# End :  Determine version of server and type  
# -------------------------------------------------------------------------------------------------

# =================================================================================================
# END:  Determine version of server and type
# =================================================================================================
# =================================================================================================


# =================================================================================================
# END:  
# =================================================================================================
# =================================================================================================


