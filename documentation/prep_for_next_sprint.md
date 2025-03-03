# Prep for Next Sprint

<br>

All in context of the `va-teams` repo

For this scenario, teams are completing a sprint of `1.16.1` and `1.17.0` work

<br>

## Release Team Action Items

Once the `1.17.0` release has been moved out of SIT and into UAT, then...

1. The next Dev Sandbox & SIT org are refreshed from UAT (in that order)

	new route:

	- New Dev box is given name like: `Dev18` for release `1.18.0`

	classic route:

    - Dev Minor release box is refreshed (Lion & Tiger)
    - Next Dev Major release box is refreshed (Astro, Blaze & Codey)
    - SIT 1 and 2 are refreshed

2. In the event of a "severed" branch is needed
    - ex: We need to move on with development but a release is still open that makes the pipeline overcrowded
    - then a Copado Pipeline connection needs to be created

<br><br>

## a CICD Manager Action Items

1. Merge old releases into `master`
    - ex: when `1.9.1` goes into Prod, all previous releases, including `1.9.1` are merged into `master`. `1.9.1` stays open in the event of fixes that need to go before `1.10.0`
    - ⚠️ TODO: Update the cascade YML to push down anything merged into `master` to the next branch based on the tag on `master`

1. Make branches for new minor release then major release
    - Create the new branch for `release/1.17.1` with `release/1.17.0` as the source
    - then create the new branch for `release/1.18.0` with `release/1.17.1` as the source

1. Create new Milestones in GitHub for the new releases

1. Create the `AUTH1180` token in GitHub for the Testing Org (ex: SIT1)

    - `sf org display --verbose` and use the Sfdx Auth Url result

1. Update the Dev Wiki with the new pipeline

    - ex: 

	| Dev Org | Release Branch (Prod date) | Branch Status | After a PR is merged they are deployed to | Dependencies |
	|:-:|:-:|:-:|:-:|-|
	| VAHC Dev18 | release/1.18.0 (TBD) | Open | SIT1 | |
	- The Dependencies section is populated by Jeff Watson in most cases

1. Run Apex Anonymous code [swapProfileToSystemAdmin](../scripts/anon/swapProfileToSystemAdmin.apex) if needed for Developer access in Dev box

<br>

*** repeat these steps if a minor release box is needed ***

<br><br>

## Developer Action Items

1. Refresh Branches

1. Run `git fetch` in terminal

1. Acquire access to Dev & SIT box
