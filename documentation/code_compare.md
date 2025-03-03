# Code Compare

<br>

## UAT or INT Comparing

1. Make sure you have access to the Org
1. Pull the latest from the release branch
1. Create a new branch from the release branch
    - Name it ex: `compare191toUAT`
1. Build the list of metadata & your package.xml ([see below](#building-the-list-of-metadata))
1. Right click and "Retrieve Source from Org" on the package.xml
1. Sift thru changes for whitespace
1. Commit Changes

<br>

### Building the List of Metadata

```
SELECT Id, copado__Metadata_API_Name__c, copado__User_Story__r.copado__Release__r.Name, copado__User_Story__r.Name, copado__User_Story__r.copado__User_Story_Title__c, copado__User_Story__c 
FROM copado__User_Story_Metadata__c 
WHERE copado__User_Story__r.copado__Release__c = 'a3kOE000000001JYAQ'
ORDER BY copado__Metadata_API_Name__c ASC
```

1. Locate the Release Id in the Copado Org using [link](https://vapm.lightning.force.com/lightning/r/copado__Project__c/a3ft00000058rguAAA/view)
    - 1.9.0 - `a3kOE00000000nNYAQ`
    - 1.9.1 - `a3kOE000000001TYAQ`
    - 1.10.0 - `a3kOE000000001JYAQ`
2. Run the SOQL above
3. Click the "Copy (Excel Format)" button from Salesforce Inspector's Data Export
4. Strip the `copado__Metadata_API_Name__c`
5. Paste into the converter
    - https://codepen.io/pastranadigital/full/NWmPWpZ

Name the PR ex: `DO NOT MERGE - Compare 1.9.1 (left) to UAT (right)`

<br><br>

## REG Comparing

Using this guide, [Git Release Audit Steps](<https://boozallen.sharepoint.com/:w:/r/teams/LITS-CCC/Shared%20Documents/04%20Development/Production%20Sustainment%20Team/Git%20Release%20Audit%20Steps%20(macOS).docx?d=w91a901eb18744154a6fc72b1cf3eae1e&csf=1&web=1&e=gK8w00>), take the following actions:

-   Make the .sh file executable `chmod u=rx ./initialize_compare.sh`
-   Enter the `<currentRelease> <previousRelease> <CopadoOrg>`
    -   ex: `./initialize_compare.sh release/1.9.1 release/1.9.0 reg`
-   Once you ran `./compare_into.sh release_1.9.1` you should open the `release_1.9.1` folder in VSCode and see the differences
-   On a diff, the left side is `release/1.9.1` and the right side is `REG`

Then:

1. Comb thru the diffs
1. Compare to package.xml
1. Click on the branch and create a new branch from HEAD
1. Name it ex: `compare191toREG`
1. Commit the diffs and publish to the va-teams repo

Name the PR ex: `DO NOT MERGE - Compare 1.9.1 (left) to UAT (right)`

<br><br>

## Pull list of metadata from PR to Excel sheet

1. Open terminal app
2. `cd /Users/omarpastrana/Desktop/GitHub/va-teams/`
3. `git diff --name-only release/1.10.0 compare110toUAT2`
4. Copy the list into the Excel sheet

