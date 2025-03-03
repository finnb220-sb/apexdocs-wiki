# 🩻 Copado - Static Code Analysis for Apex

## Check Apex Classes in Your Copado Story

On a user story with an environment inside a pipeline that has SCA settings assigned, you can request static code analysis for Apex classes related to it. To do this, navigate to the User Story record.

1. Click the drop-down menu at the top right corner. Then click `Run Static Code Analysis`
   <br><img src="images/Copado_SCA01.png" width="640px" alt="Copado user story screenshot"><br>

<br>

2. The request will then begin processing
   <br><img src="images/Copado_SCA02.png" width="640px" alt="Copado static code analysis action screenshot"><br>

<br>

3. Once it is completed (takes around 10 mins) click on the `Related` tab
   <br><img src="images/Copado_SCA03.png" width="640px" alt="Copado user story related tab screenshot"><br>

<br>

4. Scroll down to the `Static Code Analysis Results` section & click on the hyperlinked record name (ex: SCA-000000)
   <br><img src="images/Copado_SCA04.png" width="640px" alt="Copado static code analysis related list screenshot"><br>

<br>

5. This record gives an overview of the whole result. The `CodeScan Details` section is the best place to find information on the severity level at a quick glance
   <br><img src="images/Copado_SCA05.png" width="640px" alt="Copado static code analysis result record screenshot"><br>

<br>

6. On the right side, the individual violations are shown. Click the `View All` link to open the full list
   <br><img src="images/Copado_SCA06.png" width="480px" alt="Copado static code analysis violations list screenshot"><br>

<br>

7. This list is very helpful for you to see the code class and lines that have violations. The `Rule` column briefly tells you the issue. The `Severity` column can be sorted to focus on the Critical ones first
   <br><img src="images/Copado_SCA07.png" width="640px" alt="Copado static code analysis violations full list screenshot"><br>

<br>

8. By clicking on the individual records (ex: SCV-0000000) you can get more information on the rule, it’s priority and a link for more information.
   <br><img src="images/Copado_SCA08.png" width="640px" alt="Copado static code analysis violation record screenshot"><br>

<br><br>

## Copado Documentation:

-   [Run Static Code Analysis](https://docs.copado.com/articles/#!copado-ci-cd-publication/run-static-code-analysis)
-   [PMD Static Code Analysis Results](https://docs.copado.com/articles/#!copado-ci-cd-publication/pmd-sca-results)
