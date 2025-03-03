<br><img src="images/pmdbanner.png" alt="development process banner"><br>

# PMD Static Source Code Analyzer

It finds common programming flaws like unused variables, empty catch blocks, unnecessary object creation, and so forth.
<br>

🏆 Objective: Increase the quality and consistency of our code earlier in the process

[PMD Homepage](https://pmd.github.io/)

<br><br>

## Install Java

1. Using the following link, download version `17` for your operating system <br>
   https://adoptium.net/temurin/releases/?os=any&arch=any&version=17
   <br>

    - Windows users should choose the `.msi` JDK version
      <br><br>

1. Once the download is complete, install the version `17`. Pay special attention to the location of the install, it will look something like this: <br>
   Mac: `/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home` <br>
   Windows: `C:\Program Files\Eclipse Adoptium\jdk-17.0.9.9-hotspot\` <br>
   <br><img src="images/pmd09.png" width="480px" alt="VSCode extension screenshot"><br>
   <br>
1. Confirm you have successfully installed by running: `java -version`

<br><br>
<br><br>

## Install PMD & Other Extensions

1. Download the zip file from: https://github.com/pmd/pmd/releases#:~:text=pmd%2Ddist%2D7.0.0%2Drc4%2Dbin.zip
   <br><br>
1. Unzip the file
   <br><br>
1. Install the Apex Dox extension by Peter Weinberg: https://marketplace.visualstudio.com/items?itemName=PeterWeinberg.apexdox-vs-code
   <br><img src="images/pmd07.png" width="480px" alt="VSCode extension screenshot"><br>
    <!-- <br> -->
    - type `/**` and when prompted, press enter to enable the shortcut and populate a comment template
      <br><img src="images/pmd08.png" width="480px" alt="VSCode extension screenshot"><br>
      <br>
1. Install the Error Lens extension by Alexander: https://marketplace.visualstudio.com/items?itemName=usernamehw.errorlens
   <br><img src="images/pmd06.png" width="480px" alt="VSCode extension screenshot"><br>
   <br>
1. Install the Apex PMD extension by Charlie Jonas: https://marketplace.visualstudio.com/items?itemName=chuckjonas.apex-pmd
   <br><img src="images/pmd03.png" width="480px" alt="VSCode extension screenshot"><br>
   <br>
1. Open the settings menu `Ctrl/Cmd + ,` or `Ctrl + Shift + P` and enter "Open User Settings"
   <br><br>
1. Enter "PMD" in the search bar to pull up all the options we need
   <br><img src="images/pmd04.png" width="640px" alt="VSCode user settings screenshot"><br>
   <br>
1. Confirm these settings

-   "Apex PMD: Command Buffer Size" - enter `1`
-   "Apex PMD: Enable Cache" - Check the box
-   "Apex PMD: Jre Path" - Add the Java path from above ex: `/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home`
-   "Apex PMD: Rulesets" - Add Item and enter `ruleset.xml`
-   "Apex PMD: Run On File Open" - Check the box

<br><br>
<br><br>

## Using PMD

1. When you save a file you may see these in the Problems tab
   <br><img src="images/pmd05.png" width="640px" alt="VSCode pmd scan screenshot"><br>
   <br>
1. Repair and save the file to see the updated list
   <br><br>
1. DO NOT suppress any warnings

<br><br>
<br><br>

## If Needed, Update Java settings in VSCode

Close and re-open VSCode. If you see messages like this, then follow these steps:
<br><img src="images/pmd01.png" width="480px" alt="VSCode java error screenshot"><br>

1. Click on the gear and select "Manage Extension"
   <br><br>
1. On the extension page, click on the gear and select "Extension Settings"
   <br><img src="images/pmd02.png" width="320px" alt="VSCode extension settings screenshot"><br>
   <br>
1. Add the Java path from above ex: `/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home`
   <br><br>

<br><br>

[^ BACK TO TOP](#pmd-static-source-code-analyzer)
