VCC_DasWriteNoteAndSignRQ writeNoteAndSignRq = new VCC_DasWriteNoteAndSignRQ();
writeNoteAndSignRq.supplementalParameters = new List<String>{ '94450936' };
writeNoteAndSignRq.providerUserId = ''; // token
writeNoteAndSignRq.providerName = '';
writeNoteAndSignRq.providerLoginSiteCode = '984';
writeNoteAndSignRq.esig = 'TESTER';
writeNoteAndSignRq.titleIEN = '3736';
writeNoteAndSignRq.text = '|Patient Demographics|Patient Name: CHESNEY DUPLICATE|Patient Primary Address: |Caller/Recipient Relation to Patient: Self||Nursing Plan and Disposition|Referred for CCC Virtual Clinic Visit|Transferred patient to Sched & Admin-VCV||Clinical Contact Center Codes|Clinic/Location: V00-CCC DAYTSHR RN PHONE|';
writeNoteAndSignRq.patientName = 'CHESNEY DUPLICATE';
writeNoteAndSignRq.patientLocalSiteId = '984';
writeNoteAndSignRq.patientLocalPid = '552165186';
writeNoteAndSignRq.encounterString = '4348;3240605.203335;T';
writeNoteAndSignRq.cosignerDUZ = '';
writeNoteAndSignRq.authorDUZ = '';
(new VCC_DAS()).writeNoteAndSign(writeNoteAndSignRq, 'a1a3S000000WL3iQAG');
