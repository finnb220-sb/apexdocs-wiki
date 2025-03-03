# Updating Sandbox Commands

<br>

`alias orgvalidate='sf project deploy validate --verbose --source-dir force-app --wait 45'`

`alias orgdeploy='sf project deploy start --verbose --source-dir force-app --wait 45 --ignore-conflicts --test-level NoTestRun'`

<br>

## Blaze - new org

1.5.1 was the release that was in there
We wanted go to 1.5.2

Make sure the Stage 2 box gets the previous release (ex: upgrade from 1.6.1 to 1.7.0 before 1.7.1 goes in)

Get thisforce://<clientId>:<clientSecret>:<refreshToken>@va-vet--vahcstage2.sandbox.my.salesforce.com
By

1. Connecting VSCode to the org
2. Running `sf org display --verbose`
   Thanks to:
   https://dx.appirio.com/project-setup/salesforce-dx-auth/

-   Branched off 1.5.2 and that feature branch was where we fixed any deployment issues

-   sf project deploy validate --verbose --source-dir force-app --wait 45

🚨 Work the errors

Once the validation was successful

-   sf project deploy start --verbose --source-dir force-app --wait 45 --ignore-conflicts --test-level NoTestRun

For 1.6.0 into Codey:

-   Deactivated Medication Renewal on VCC_Administrative_Note_Reason\_\_c
-   Made a new branch from 1.6.0 and then “fixed” on that then validated that branch. This included deleting files or pulling the updated parts from the org

Updated the branches by creating a new release and tagging the oldest release
If you need to delete: git push --delete origin freeze/1.5.2.1

If HDR isn’t coming back:Make a new VCC_Org_Setting\_\_mdt record for the dev org
￼

When switching/catching up a Stage environment, I did the same thing that I did for creating a new dev environment. I made a feature branch and validated it to get the working state then deployed it

Freeze Release
￼

Getting the auth token
sfdx force:org:display -u alias --verbose

