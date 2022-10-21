$C_MAIN_TEMPLATE = "#include <stdio.h>
#include <stdlib.h>

int main(int argc, char const *argv[])
{
    /* code */
    return 0;
}
"

$CPP_MAIN_TEMPLATE = "#include <iostream>

int main(int argc, char const *argv[])
{
    /* code */
    return 0;
}
"

Function GetMakefile {
    Param (
        [Parameter(Mandatory=$true)]
        [String]
        $LANG
    ,
        [Parameter(Mandatory=$true)]
        [String]
        $SIZE
    ,
        [Parameter(Mandatory=$true)]
        [String]
        $PATH
    )
    Process {
        $URL_C_SMALL = "https://raw.githubusercontent.com/BragdonD/makefile/main/c/small-middle-size-project/makefile"
        $URL_C_BIG = "https://raw.githubusercontent.com/BragdonD/makefile/main/c/big-project/makefile"
        $URL_CPP_SMALL = "https://raw.githubusercontent.com/BragdonD/makefile/main/cpp/small-middle-size-project/makefile"
        $URL_CPP_BIG = "https://raw.githubusercontent.com/BragdonD/makefile/main/cpp/big-project/makefile"
        try {
            if($LANG -eq "c" -or "C") {
                if($SIZE -eq "s" -or "small" -or "S") {
                    (New-Object System.Net.WebClient).DownloadFile($URL_C_SMALL,"$PATH\makefile")
                }
                if($SIZE -eq "b" -or "B" -or "big") {
                    (New-Object System.Net.WebClient).DownloadFile($URL_C_BIG, "$PATH\makefile")
                }
            }
            if($LANG -eq "cpp" -or "CPP" -or "c++" -or "C++") {
                if($SIZE -eq "s" -or "small" -or "S") {
                    (New-Object System.Net.WebClient).DownloadFile($URL_CPP_SMALL, "$PATH\makefile")
                }
                if($SIZE -eq "b" -or "B" -or "big") {
                    (New-Object System.Net.WebClient).DownloadFile($URL_CPP_BIG, "$PATH\makefile")
                }
            }
        }
        catch {
            Write-Warning -Message "Failed to retrieve makefile."
        }
    }
}

Function GenerateDirectoryTemplate {
    Param (
        [Parameter(Mandatory=$true)]
        [String]
        $PATH
    ,
        [Parameter(Mandatory=$true)]
        [String]
        $NAME
    )
    Process {
        $FULL_PATH = $PATH + "\" + $NAME
        try {
            New-Item -Path $FULL_PATH -ItemType Directory -ErrorAction Stop
        }
        catch {
            Write-Host "Seems like this directory already exists..."
            $VALIDATION = Read-Host -Prompt 'Do you want to overwrite it ? (Y/N)'
            if($VALIDATION -eq "Y" -or "y") {
                New-Item -Path $FULL_PATH -ItemType Directory -ErrorAction Stop -Force
            }
            else {
                Write-Warning -Message "Exited Project Creation."
            }
        }
        # We consider that if one of the two subfolder already exists then the other must exists too.
        try {
            New-Item -Path "$FULL_PATH\inc" -ItemType Directory -ErrorAction Stop
            New-Item -Path "$FULL_PATH\src" -ItemType Directory -ErrorAction Stop
        }
        catch {
            Write-Host "Seems like this directory is not empty..."
            $VALIDATION = Read-Host -Prompt 'Do you want to overwrite it ? (Y/N)'
            if($VALIDATION -eq "Y" -or "y") {
                New-Item -Path "$FULL_PATH\inc" -ItemType Directory -ErrorAction Stop -Force
                New-Item -Path "$FULL_PATH\src" -ItemType Directory -ErrorAction Stop -Force
            }
        }
    }
}

Function GenerateFileTemplate {
    Param (
        [Parameter(Mandatory=$true)]
        [String]
        $LANG
    ,
        [Parameter(Mandatory=$true)]
        [String]
        $PATH
    )
    Process {
        if($LANG -eq "c") {
            New-Item -Path "$PATH\src\main.c" -Value $C_MAIN_TEMPLATE
        }
        if($LANG -eq "cpp") {
            New-Item -Path "$PATH\src\main.cpp" -Value $CPP_MAIN_TEMPLATE
        }
    }
}

Function GenerateProject {
    Param (
        [Parameter(Mandatory=$true)]
        [String]
        $LANG
    ,
        [Parameter(Mandatory=$true)]
        [String]
        $PATH
    ,
        [Parameter(Mandatory=$true)]
        [String]
        $SIZE
    ,
        [Parameter(
            Mandatory=$true,
            HelpMessage = 'Lower case, no special characters, no symbols, no numbers, no extension'
        )]
        [ValidatePattern("([a-zA-Z])*")]
        [String]
        $NAME
    )
    Process 
    {
        $PATH_EXIST = Test-Path -Path $PATH
        $PATH_VALID = Test-Path -Path $PATH -PathType Container -IsValid
        if(!$PATH_VALID) {
            Throw Write-Warning -Message "Invalid Path for the new project. Path given was ${PATH}"
        }
        if(!$PATH_EXIST) {
            New-Item -Path $PATH -ItemType Directory
        }
        else {
            Write-Host "Creating project ${LANG} template in ${PATH}"
        }
        GenerateDirectoryTemplate -PATH $PATH -NAME $NAME
        GetMakefile -PATH "$PATH\$NAME" -LANG $LANG -SIZE $SIZE
        GenerateFileTemplate -PATH "$PATH\$NAME" -LANG $LANG
    }
}